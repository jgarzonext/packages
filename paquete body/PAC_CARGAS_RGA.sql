--------------------------------------------------------
--  DDL for Package Body PAC_CARGAS_RGA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGAS_RGA" IS
   /******************************************************************************
      NOMBRE:      PAC_CARGAS_RGA
      PROPÓSITO: Funciones para la gestión de la carga de procesos
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        05/07/2010   ICV              1. Creación del package.
      2.0        29/06/2010   DRA              2. 0016130: CRT - Error informando el codigo de proceso en carga
      3.0        13/10/2010   FAL              3. 0014888: CRT002 - Carga de polizas,recibos y siniestros Allianz
      4.0        18/10/2010   FAL              4. 0016324: CRT - Configuracion de las cargas
      5.0        03/11/2010   FAL              5. 0016525: CRT002 - Incidencias en cargas (primera carga inicial)
      6.0        03/11/2010   ICV              6. 0017174: CRT002 - Càrrega fitxer RGA
      7.0        14/01/2011   JRH              7. 0017159: CRT002 - Carga de productos de ahorro (CTASEGURO), pensiones, unit link de RGA
      8.0        19/01/2011   ICV              8. 0017155: CRT003 - Informar estado actualizacion compañia
      9.0        02/03/2011   FAL              9. 0017569: CRT - Interfases y gestión personas
     10.0        26/04/2011   ICV             10. 0017174: CRT002 - Càrrega fitxer RGA
     11.0        22/07/2013   NMM             11. 27616: CRT904-Error proceso de carga 480177
     12.0        30/04/2014   FAL             12. 0027642: RSA102 - Producto Tradicional
   ******************************************************************************/

   /*************************************************************************
            1.0.0.0.0 f_ejecutar_carga
      1.1.0.0.0 ....f_ejecutar_carga_fichero
      1.2.0.0.0 ....f_ejecutar_carga_proceso
      1.2.1.0.0 ........f_alta_poliza.............(ALTA)
      1.2.2.0.0 ........f_alta_poliza_seg.........(ALTA)
      1.2.3.0.0 ........f_modi_poliza.............(MODI)
      1.2.4.0.0 ........f_baja_poliza.............(BAJA)
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
      -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
      p_id_ext IN VARCHAR2,
      -- Fi Bug 14888
      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
      p_ncarg IN NUMBER   -- Fi Bug 16324
                       )
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.P_MARCALINEA';
      num_err        NUMBER;
      vtipo          NUMBER;
      num_lin        NUMBER;
      num_aux        NUMBER;
   BEGIN
      IF p_tip = 'ALTA' THEN
         vtipo := 0;
      ELSE
         vtipo := 0;
      END IF;

      num_err :=
         pac_gestion_procesos.f_set_carga_ctrl_linea
               (p_pro, p_lin, vtipo, p_lin, p_tip, p_est, p_val, p_seg,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                p_id_ext,   -- Fi Bug 14888
                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                p_ncarg,   -- Fi Bug 16324
                NULL, NULL, NULL, NULL);

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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.P_MARCALINEAERROR';
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
          param in x : registro tipo int_rga
          param in psinterf: id interfase obtenido en la busqueda persona host
          return : 0 si ha ido bien
    *************************************************************************/
   FUNCTION f_alta_persona_host(
      x IN OUT int_rga%ROWTYPE,
      psinterf IN int_mensajes.sinterf%TYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.F_ALTA_PERSONA_HOST';
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
             WHERE nnumide = x.nif_tomador;
         EXCEPTION
            WHEN OTHERS THEN
               wnnumnif := x.nif_tomador;
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

         IF x.nif_tomador <> x.nif THEN
            wsperson := NULL;

            BEGIN
               SELECT sperson
                 INTO wsperson
                 FROM per_personas
                WHERE nnumide = x.nif;
            EXCEPTION
               WHEN OTHERS THEN
                  wnnumnif := x.nif;
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
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN err_busca_pers THEN
         pac_cargas_rga.p_genera_logs
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

         pac_cargas_rga.p_genera_logs(vobj, vtraza, 'Error en alta host',
                                      ' Error: ' || werror || '; sinterf: ' || wsinterf
                                      || '; sperson = ' || wsperson || ' (' || x.proceso || '-'
                                      || x.nlinea || ')',
                                      x.proceso,
                                      'Error en alta host: ' || werror || '; sperson = '
                                      || wsperson || ' (' || x.proceso || '-' || x.nlinea
                                      || ')');
         pterror := werror || '; sinterf: ' || wsinterf || '; sperson = ' || wsperson;
         RETURN 2;
      WHEN OTHERS THEN
         pterror := 'Error no controlado an alta persona en Host' || SQLERRM;
         RETURN 1;
   END f_alta_persona_host;

   -- Fi Bug 17569

   /*************************************************************************
                Función que da de alta póliza en las SEG
          param in x : registro tipo int_RGA
          return : 1 si ha habido error
                   2 si ha habido warning
                   4 si ha ido bien
      *************************************************************************/
   FUNCTION f_alta_poliza_seg(
      x IN OUT int_rga%ROWTYPE,
      psinterf IN int_mensajes.sinterf%TYPE)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.F_ALTA_POLIZA_SEG';
      v_i            BOOLEAN := FALSE;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
      verrorgrab     EXCEPTION;
      vtraza         NUMBER := 0;
      vtiperr        NUMBER;
      vsseguro       NUMBER;
      terror         VARCHAR2(3000);
      warning_alta_host BOOLEAN := FALSE;
   BEGIN
      vtraza := 100;
      pac_mig_axis.p_migra_cargas(x.nlinea, 'M', x.ncarga, 'DEL');
      --Cargamos las SEG para la póliza (ncarga)
      vtraza := 110;

      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 200;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, 'ALTA', 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
                  NULL;
            END;

            vnum_err :=
               p_marcalinea
                  (x.proceso, x.nlinea, 'ALTA', 2, 1, vsseguro,
                   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.poliza_participe,   -- Fi Bug 14888
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
            IF k_busca_host = 1 THEN
               -- FAL. 28/06/2011. Parametrizar la busqueda de personas host
               vnum_err := f_alta_persona_host(x, psinterf, terror);

               IF vnum_err <> 0 THEN
                  vnum_err := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 2, 1, vsseguro,

                                           -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                           x.poliza_participe,   -- Fi Bug 14888
                                           -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                           x.ncarga   -- Fi Bug 16324
                                                   );

                  IF vnum_err <> 0 THEN
                     --Si fallan estas funciones de gestión salimos del programa
                     RAISE verrorgrab;
                  END IF;

                  IF NOT warning_alta_host THEN
                     vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145,
                                                   terror);

                     IF vnum_err <> 0 THEN
                        --Si fallan estas funciones de gestión salimos del programa
                        RAISE verrorgrab;
                     END IF;

                     warning_alta_host := TRUE;
                  END IF;
               END IF;
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
               NULL;
         END;

         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, 'ALTA', 4, 1, vsseguro,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE verrorgrab;
         END IF;

         -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
         IF k_busca_host = 1 THEN
            -- FAL. 28/06/2011. Parametrizar la busqueda de personas host
            vnum_err := f_alta_persona_host(x, psinterf, terror);

            IF vnum_err <> 0 THEN
               vnum_err := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 2, 1, vsseguro,

                                        -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                        x.poliza_participe,   -- Fi Bug 14888
                                        -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                        x.ncarga   -- Fi Bug 16324
                                                );

               IF vnum_err <> 0 THEN
                  --Si fallan estas funciones de gestión salimos del programa
                  RAISE verrorgrab;
               END IF;

               vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, terror);

               IF vnum_err <> 0 THEN
                  --Si fallan estas funciones de gestión salimos del programa
                  RAISE verrorgrab;
               END IF;
            END IF;
         END IF;

         -- Fi Bug 0017569
         vtiperr := 4;
      END IF;

      IF vtiperr IN(4, 2) THEN   --actualizamos el ncarga
         BEGIN
            SELECT sseguro
              INTO vsseguro
              FROM mig_seguros
             WHERE ncarga = x.ncarga;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;

         BEGIN
            UPDATE seguros
               SET cpolcia = x.poliza_participe
             WHERE sseguro = vsseguro;
         EXCEPTION
            WHEN OTHERS THEN
               pac_cargas_rga.p_genera_logs(vobj, vtraza, SQLCODE,
                                            'Error al guardar cpolcia ' || x.poliza_participe,
                                            x.proceso,
                                            'Error al guardar cpolcia ' || x.poliza_participe);
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

/*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************

--JRH INICIO PARTE AHORRO

AHORRO
CTASEGURO
RENTAS
SINIESTROS/TRASPASOS/PRESTACIONES/RESCATES
SALDO

*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************/

   /*************************************************************************
      Funcion que inserta en ctaseguro al cobrar/desanular un recibo/renta/pagosiniestro o crear un saldo
      param  x in out: Registro tipo int_rga.
      param  p_n_seg in : Es el sseguro de lap´póliza
      param p_tipo_oper : 1 Saldo/2 Recibo/ 3 Renta / 4 Siniestro
      param pnrecibo in : Recibos cobrado o devuelto
      param psidepag in  : Pago de siniestro cobrado o devuelto
      param psrecren in : Renta cobrada o devuelta
      param pimpsaldo in : Importe Saldo
      param ptiposaldo in : Tipo de saldo (por defecto 0, pero pordrian haber derechos consolidados) Poner PB aqui tabién.
      param pdevolu in : Si es una devolución (por defecto false)
      devuelve 0 para correcto o número error.

      --JRH Si no se creasen siniestros, psidepag podria ser el importe del siniesrtro y se tendría que pasar
      por parámetro el tipo de siniestro para insertar en ctaseguro
      *************************************************************************/
   FUNCTION f_crea_ctaseguro(
      x IN OUT int_rga%ROWTYPE,
      p_n_seg IN NUMBER,
      p_tipo_oper IN NUMBER,
      pnrecibo IN NUMBER,
      psidepag IN NUMBER,
      psrecren IN NUMBER,
      pimpsaldo IN NUMBER,
      ptiposaldo IN NUMBER DEFAULT 0,
      pdevolu IN BOOLEAN DEFAULT FALSE)
      RETURN NUMBER IS
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_ctaseguro mig_ctaseguro%ROWTYPE;
      v_mig_ctaseguro_libreta mig_ctaseguro_libreta%ROWTYPE;
      vcontmov       NUMBER;
      vtraza         NUMBER;
      vccapgar       NUMBER := NULL;
      vccapfal       NUMBER := NULL;
      vigasext       NUMBER := NULL;
      vigasint       NUMBER := NULL;
      vn_mov         NUMBER;
      errdatos       EXCEPTION;
      vimporte       NUMBER;
      vmot           NUMBER;
      v_reg_recibos  recibos%ROWTYPE;
      v_reg_pagosrenta pagosrenta%ROWTYPE;
      p_deserror     VARCHAR2(200);
      v_ncarga       NUMBER;
      vnum_err       NUMBER;
      v_seq          NUMBER;
      vcerror        NUMBER;
      v_rowid        ROWID;
      vn_aux         NUMBER;
      vnsinies       NUMBER;
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
      vcagrpro       NUMBER;
      vsproduc       NUMBER;
      vfecha         DATE;
      vncesta        planpensiones.ccodpla%TYPE;
      vcramo         seguros.cramo%TYPE;

      CURSOR cur_segdisin2_act(seguro NUMBER) IS
         SELECT sseguro, ccesta, pdistrec, pdistuni, pdistext
           FROM segdisin2
          WHERE sseguro = seguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = seguro
                              AND ffin IS NULL)
            AND ffin IS NULL;
   BEGIN
      --Inicializamos la cabecera de la carga
      vtraza := 1500;

      --IF p_tipo_oper = 2 THEN
      SELECT cagrpro, sproduc, cramo
        INTO vcagrpro, vsproduc, vcramo
        FROM seguros
       WHERE sseguro = p_n_seg;

      IF x.empresa NOT IN(12, 13)
         OR vcramo = 82   -- si es de vida riesgo no tiene ctaseguro
                       THEN
         RETURN 0;
      END IF;

      --END IF;
      IF p_n_seg IS NULL THEN
         vcerror := 107839;
         p_deserror := 'Parámetros seguro nulo al migrar ctaseguro';
         RAISE errdatos;
      END IF;

      IF p_tipo_oper IS NULL THEN
         vcerror := 107839;
         p_deserror := 'Parámetros tipo operación al migrar ctaseguro';
         RAISE errdatos;
      END IF;

      IF p_tipo_oper NOT IN(1, 2, 3, 4) THEN
         vcerror := 107839;
         p_deserror := 'Valor tipo operación incorrecto al migrar ctaseguro';
         RAISE errdatos;
      END IF;

      vtraza := 1505;

      IF pnrecibo IS NULL
         AND psrecren IS NULL
         AND psidepag IS NULL
         AND pimpsaldo IS NULL THEN
         vcerror := 107839;
         p_deserror :=
                 'Parámetros nulos (pnrecibo, sidepag, impsaldo, srecren) al migrar ctaseguro';
         RAISE errdatos;
      END IF;

      vtraza := 1506;

      IF p_tipo_oper = 1   --Saldo
         AND pimpsaldo IS NULL THEN
         vcerror := 107839;
         p_deserror := 'Parámetros pimpsaldo al migrar ctaseguro';
         RAISE errdatos;
      ELSE
         IF pimpsaldo IS NOT NULL THEN
            vfecha := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr');
         END IF;
      END IF;

      vtraza := 1507;

      IF p_tipo_oper = 2 THEN   --Cobro recibo
         IF pnrecibo IS NULL THEN
            vcerror := 152326;
            p_deserror := 'Falta informar el número de recibo';
            RAISE errdatos;
         ELSE
            BEGIN
               SELECT *
                 INTO v_reg_recibos
                 FROM recibos
                WHERE nrecibo = pnrecibo;

               vfecha := v_reg_recibos.fefecto;
            EXCEPTION
               WHEN OTHERS THEN
                  p_deserror := 'Error en recibo:' || pnrecibo || ' ' || SQLERRM;
                  RAISE errdatos;
            END;
         END IF;
      END IF;

      vtraza := 1508;

      IF p_tipo_oper = 3 THEN   --Cobro pago siniestro
         IF psidepag IS NULL THEN
            vcerror := 103504;
            p_deserror := 'Falta informar el pago';
            RAISE errdatos;
         ELSE
            BEGIN
               SELECT fordpag
                 INTO vfecha
                 FROM sin_tramita_pago
                WHERE sidepag = psidepag;
            EXCEPTION
               WHEN OTHERS THEN
                  p_deserror := 'Error en pago de siniestro:' || psidepag || ' ' || SQLERRM;
                  RAISE errdatos;
            END;
         END IF;
      END IF;

      vtraza := 1509;

      IF p_tipo_oper = 4 THEN   --Cobro renta
         IF psrecren IS NULL THEN
            vcerror := 108850;
            p_deserror := 'Falta informar el pago de la renta';
            RAISE errdatos;
         ELSE
            BEGIN
               SELECT ffecefe
                 INTO vfecha
                 FROM pagosrenta
                WHERE srecren = psrecren;
            EXCEPTION
               WHEN OTHERS THEN
                  p_deserror := 'Error en renta:' || psrecren || ' ' || SQLERRM;
                  RAISE errdatos;
            END;
         END IF;
      END IF;

      vtraza := 1510;
      v_ncarga := f_next_carga;
      vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Ctaseguro', v_seq);
      vtraza := 1520;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

-------------------- INICI ---------------------
      vtraza := 1525;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SEGUROS', 0);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_CTASEGURO', 1);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_CTASEGURO_LIBRETA', 2);

      vtraza := 1530;

      SELECT NVL(MAX(nnumlin), 0) + 1
        INTO vcontmov
        FROM ctaseguro
       WHERE sseguro = p_n_seg;

      vtraza := 1540;
      v_mig_ctaseguro.mig_pk := v_ncarga || '-' || x.poliza_participe || '-' || x.producto;
      v_mig_ctaseguro.mig_fk := v_mig_ctaseguro.mig_pk;
      v_mig_ctaseguro.ncarga := v_ncarga;
      v_mig_ctaseguro.cestmig := 1;
      v_mig_ctaseguro.nnumlin := vcontmov;
      --v_mig_ctaseguro.fcontab := NVL(vfecha, TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'));
      v_mig_ctaseguro.fcontab := NVL(vfecha, TO_DATE(x.fec_fin_periodo, 'dd/mm/rrrr'));
      vtraza := 1545;

      IF v_mig_ctaseguro.fcontab IS NULL THEN
         p_deserror := 'Fecha de inicio de periodo nula';
         vcerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1546;
      v_mig_ctaseguro.fvalmov := v_mig_ctaseguro.fcontab;
      v_mig_ctaseguro.ffecmov := v_mig_ctaseguro.fcontab;
      v_mig_ctaseguro.sseguro := 0;
      v_mig_ctaseguro.ccalint := 0;
      v_mig_ctaseguro.cmovanu := 0;
      vtraza := 1547;

      IF pnrecibo IS NOT NULL THEN
         SELECT SUM(iconcep)
           INTO vimporte
           FROM detrecibos
          WHERE nrecibo = pnrecibo
            AND cconcep = 0;

         vtraza := 1550;
         vtraza := 1555;

         IF v_reg_recibos.ctiprec = 4 THEN   --Aport extr
            vmot := 1;
         ELSIF v_reg_recibos.ctiprec IN(0, 3) THEN
            vmot := 2;
         ELSIF v_reg_recibos.ctiprec = 9 THEN   --Extorno
            vmot := 51;
         ELSIF v_reg_recibos.ctiprec = 10 THEN   --Extorno
            vmot := 8;
         ELSE
            vmot := 2;
         END IF;

         vtipomovulk := 45;

         IF pdevolu THEN
            vmot := 51;   --Anulación
            vtipomovulk := 58;
         END IF;

         v_mig_ctaseguro.nrecibo := pnrecibo;

         SELECT smovrec
           INTO v_mig_ctaseguro.smovrec
           FROM movrecibo
          WHERE nrecibo = pnrecibo
            AND fmovfin IS NULL;
      ELSIF psrecren IS NOT NULL THEN
         vtraza := 1560;

          --JRH Si no se creasen rentas, (pagosrenta, srecren) srecren podria ser el importe de la renta.
         --Srecren se dejaría a null en ctaseguro
         BEGIN
            SELECT *
              INTO v_reg_pagosrenta
              FROM pagosrenta
             WHERE srecren = psrecren;
         EXCEPTION
            WHEN OTHERS THEN
               p_deserror := 'Error en renta:' || psrecren;
               RAISE errdatos;
         END;

         vtraza := 1565;
         vimporte := v_reg_pagosrenta.isinret;
         vmot := 53;
         vtipomovulk := 53;   --JRH IMP ?

         IF pdevolu THEN
            vmot := 10;   --Anulación
            vtipomovulk := 90;   --JRH IMP ?
         END IF;

         v_mig_ctaseguro.srecren := psrecren;
      ELSIF psidepag IS NOT NULL THEN
         --JRH Si no se creasen siniestros, (sin_tramita_pago,sidepag,nsinies,sin_siniestro) psidepag podria ser el importe del siniestro y se tendría que pasar
         -- por parámetro el tipo de siniestro para insertar en ctaseguro el cmovimi coresppondiente
         --NSINIES, SIDEPAG se dejarían a null en ctaseguro
         BEGIN
            SELECT DISTINCT s.nsinies, s.ccausin, s.cmotsin, p.isinret
                       INTO vnsinies, vccausin, vcmotsin, visinret
                       FROM sin_tramita_pago p, sin_siniestro s
                      WHERE p.sidepag = psidepag
                        AND s.nsinies = p.nsinies;
         EXCEPTION
            WHEN OTHERS THEN
               p_deserror := 'Error en pago:' || psidepag;
               RAISE errdatos;
         END;

         vimporte := visinret;
         vtraza := 1555;

         IF vccausin = 4 THEN   --Rescate Total
            vmot := 34;
            vtipomovulk := 94;

            IF vimporte < 0 THEN
               vmot := 10;
               vtipomovulk := 90;
            END IF;
         ELSIF vccausin = 5 THEN   --Rescate Parcial
            vmot := 33;
            vtipomovulk := 93;

            IF vimporte < 0 THEN
               vmot := 10;
               vtipomovulk := 90;
            END IF;
         ELSIF vccausin = 3 THEN   --vto
            vmot := 32;
            vtipomovulk := 92;

            IF vimporte < 0 THEN
               vmot := 10;
               vtipomovulk := 90;
            END IF;
         ELSIF vccausin = 8 THEN   --traspaso
            vmot := 47;
            vtipomovulk := 97;

            IF vimporte < 0 THEN
               vmot := 10;
               vtipomovulk := 90;
            END IF;
         ELSE   --Siniestro
            vmot := 31;
            vtipomovulk := 91;

            IF vimporte < 0 THEN
               vmot := 10;
               vtipomovulk := 90;
            END IF;
         END IF;

         IF pdevolu THEN
            vmot := 10;   --Anulación
            vtipomovulk := 90;   --JRH IMP ?
         END IF;

         v_mig_ctaseguro.nsinies := vnsinies;
      -- v_mig_ctaseguro.sidepag := psidepag;
      ELSE
         vimporte := pimpsaldo;
         vmot := ptiposaldo;   --Saldo
         vccapfal := x.capital_asegurado;
         vccapgar := x.imp_capital_final_vida;

         --JRH 17/02/2011
         IF vmot <> 0 THEN
            vccapfal := 0;
            vccapgar := 0;
         END IF;

         --JRH 17/02/2011
         vigasext := 0;
         vigasint := 0;
      END IF;

      v_mig_ctaseguro.imovimi := NVL(vimporte, 0);
      v_mig_ctaseguro.cmovimi := vmot;
      -- Necesitamos informar mig_seguros para join con mig_ctaseguro
      vtraza := 1570;
       -- jlb 22/02/2011-- inserto sino existen las preguntas para luego calcular el
      -- capital asegurado 7957, total primas pagadas 7958, Valor rescate 7959
      vtraza := 1574;

      SELECT v_ncarga ncarga, -4 cestmig, v_mig_ctaseguro.mig_pk mig_pk,
             v_mig_ctaseguro.mig_pk mig_fk, cagente, npoliza, ncertif,
             fefecto, creafac, cactivi, ctiprea,
             cidioma, cforpag, cempres, sproduc,
             casegur, nsuplem, sseguro, 0 sperson
        INTO v_mig_seg.ncarga, v_mig_seg.cestmig, v_mig_seg.mig_pk,
             v_mig_seg.mig_fk, v_mig_seg.cagente, v_mig_seg.npoliza, v_mig_seg.ncertif,
             v_mig_seg.fefecto, v_mig_seg.creafac, v_mig_seg.cactivi, v_mig_seg.ctiprea,
             v_mig_seg.cidioma, v_mig_seg.cforpag, v_mig_seg.cempres, v_mig_seg.sproduc,
             v_mig_seg.casegur, v_mig_seg.nsuplem, v_mig_seg.sseguro, v_mig_seg.sperson
        FROM seguros
       WHERE sseguro = p_n_seg;

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

      -- jlb 22/02/2011-- inserto sino existen las preguntas para luego calcular el
      -- capital asegurado 7957, total primas pagadas 7958, Valor rescate 7959
      -- No puede usar las migpreguntas, porque no permite actualizar, y no quiero crear un movimiento nuevo en pregunseg
      BEGIN
         INSERT INTO pregunseg
                     (sseguro, nriesgo, cpregun, crespue, nmovimi, trespue)
              VALUES (p_n_seg, 1, 7957, x.imp_capital_final_vida, vn_mov, NULL);
      EXCEPTION
         WHEN OTHERS THEN
            UPDATE pregunseg
               SET crespue = x.imp_capital_final_vida
             WHERE sseguro = p_n_seg
               AND nmovimi = vn_mov
               AND nriesgo = 1
               AND cpregun = 7957;
      END;

      vtraza := 1581;

      BEGIN
         INSERT INTO pregunseg
                     (sseguro, nriesgo, cpregun, crespue, nmovimi, trespue)
              VALUES (p_n_seg, 1, 7958, x.importe_facturacion_acumulada, vn_mov, NULL);
      EXCEPTION
         WHEN OTHERS THEN
            UPDATE pregunseg
               SET crespue = x.importe_facturacion_acumulada
             WHERE sseguro = p_n_seg
               AND nmovimi = vn_mov
               AND nriesgo = 1
               AND cpregun = 7958;
      END;

      vtraza := 1582;

      BEGIN
         INSERT INTO pregunseg
                     (sseguro, nriesgo, cpregun, crespue, nmovimi, trespue)
              VALUES (p_n_seg, 1, 7959, NVL(x.importe_valor_rescate, 0), vn_mov, NULL);
      EXCEPTION
         WHEN OTHERS THEN
            UPDATE pregunseg
               SET crespue = NVL(x.importe_valor_rescate, 0)
             WHERE sseguro = p_n_seg
               AND nmovimi = vn_mov
               AND nriesgo = 1
               AND cpregun = 7959;
      END;

      vtraza := 1585;

      INSERT INTO mig_seguros
           VALUES v_mig_seg
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

      vtraza := 1590;
      vtraza := 1600;
      --Ctaseguro Libreta
      v_mig_ctaseguro_libreta := NULL;
      --Un recibo como inicio tiene un movimiento de Pendiente.
      v_mig_ctaseguro_libreta.ncarga := v_ncarga;
      v_mig_ctaseguro_libreta.cestmig := 1;
      v_mig_ctaseguro_libreta.mig_pk := v_mig_ctaseguro.mig_pk;
      v_mig_ctaseguro_libreta.mig_fk := v_mig_ctaseguro.mig_fk;
      v_mig_ctaseguro_libreta.nmovimi := vn_mov;
      v_mig_ctaseguro_libreta.fcontab := v_mig_ctaseguro.fcontab;
      v_mig_ctaseguro_libreta.sseguro := 0;
      v_mig_ctaseguro_libreta.nnumlin := v_mig_ctaseguro.nnumlin;
      v_mig_ctaseguro_libreta.ccapgar := vccapgar;
      v_mig_ctaseguro_libreta.ccapfal := vccapfal;
      v_mig_ctaseguro_libreta.igasext := vigasext;
      v_mig_ctaseguro_libreta.igasint := vigasint;

      --buscar cesta asignada al producto.
      SELECT MAX(c.ccodfon)
        INTO vncesta
        FROM proplapen b, planpensiones c
       WHERE b.sproduc = v_mig_seg.sproduc
         AND c.ccodpla = b.ccodpla;

      IF   --p_tipo_oper <> 1
         p_tipo_oper = 1   -- saldo
         --AND NVL(x.valor_participacion, 0) <> 0 THEN
         AND NVL(x.num_partipaciones, 0) <> 0 THEN
         v_mig_ctaseguro.nunidad := x.num_partipaciones;
      -- jlb 21/02/2011 xidistrib / viuniact;
      END IF;

      v_mig_ctaseguro.cesta := vncesta;

      INSERT INTO mig_ctaseguro
           VALUES v_mig_ctaseguro
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 1, v_mig_ctaseguro.mig_pk);

      INSERT INTO mig_ctaseguro_libreta
           VALUES v_mig_ctaseguro_libreta
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 2, v_mig_ctaseguro.mig_pk);

/*
      --Caso de participaciones (Unit Link, Planes de Pensiones)
      IF p_tipo_oper <> 1
         AND NVL(x.valor_participacion, 0) <> 0 THEN
-- jlb 21/02/2011 -- quiero la cesta

         --buscar cesta asignada al producto.
         SELECT MAX(c.ccodfon)
           INTO vncesta
           FROM proplapen b, planpensiones c
          WHERE b.sproduc = v_mig_seg.sproduc
            AND c.ccodpla = b.ccodpla;

            -- comprobar si existe valor para la fecha.
--          SELECT COUNT(1)
  --            INTO v_naux
    --          FROM tabvalces d
    --         WHERE d.ccesta = v_ncesta
    --         AND d.fvalor = v_ffecvalces;
   --
--

         -- jlb 21/02/2011        FOR valor IN cur_segdisin2_act(p_n_seg) LOOP
         viuniact := x.valor_participacion;
         -- jlb 21/02/2011 vacumpercent := vacumpercent + (vimporte * valor.pdistrec) / 100;
         -- jlb 21/02/2011 xidistrib := ROUND(vacumpercent - vacumrounded, 2);
         -- jlb 21/02/2011 vacumrounded := vacumrounded + ROUND(vacumpercent - vacumrounded, 2);
         -- Calcula les distribucions
         --xidistrib := (xitotalr * valor.pdistrec) / 100;
         xidistrib := x.num_partipaciones;
         --Obtenemos el estado de la cesta (consultamos el estado en que están sus fondos a fecha de efecto)
         --jlb 21/02/2011 vnerror := pac_val_finv.f_valida_estado_cesta(valor.ccesta, vvalorf, vestado);

         --jlb 21/02/2011
           --IF vestado = 'C' THEN
             -- hi_hac := hi_hac + 1;
            --END IF;

         vbucle := vbucle + 1;
         v_mig_ctaseguro := NULL;
         v_mig_ctaseguro.mig_pk := v_ncarga || '-' || x.poliza_participe || '-' || x.producto;
         v_mig_ctaseguro.mig_fk := v_mig_seg.mig_pk;
         v_mig_ctaseguro.mig_pk := v_mig_ctaseguro.mig_pk || '-' || vbucle;
         v_mig_ctaseguro.ncarga := v_ncarga;
         v_mig_ctaseguro.cestmig := 1;
         v_mig_ctaseguro.nnumlin := vcontmov + vbucle;
         v_mig_ctaseguro.fcontab := vfecha;
         vtraza := 2000;

         IF v_mig_ctaseguro.fcontab IS NULL THEN
            p_deserror := 'Fecha de inicio de periodo nula';
            vcerror := 1000135;
            RAISE errdatos;
         END IF;

         vtraza := 2010;
         v_mig_ctaseguro.fvalmov := v_mig_ctaseguro.fcontab;
         v_mig_ctaseguro.ffecmov := v_mig_ctaseguro.fcontab;
         v_mig_ctaseguro.sseguro := 0;
         v_mig_ctaseguro.ccalint := 0;
         v_mig_ctaseguro.cmovanu := 0;
         v_mig_ctaseguro.imovimi := NVL(xidistrib, 2);   --JRH IMP o  NVL(nnn,0)?
         v_mig_ctaseguro.cmovimi := vtipomovulk;
         v_mig_ctaseguro.cestado := 2;
         vtraza := 2020;

         IF pnrecibo IS NOT NULL THEN
            v_mig_ctaseguro.nrecibo := pnrecibo;
         ELSIF psrecren IS NOT NULL THEN
            v_mig_ctaseguro.srecren := psrecren;
         ELSIF psidepag IS NOT NULL THEN
            --    v_mig_ctaseguro.sidepag := psidepag;
            v_mig_ctaseguro.nsinies := vnsinies;
         END IF;

         vtraza := 2021;
         v_mig_ctaseguro.cesta := vncesta;
         v_mig_ctaseguro.nunidad := x.valor_participacion;   -- jlb 21/02/2011 xidistrib / viuniact;
         v_mig_ctaseguro.fasign := v_mig_ctaseguro.fvalmov;
         v_mig_ctaseguro_libreta := NULL;
         --Un recibo como inicio tiene un movimiento de Pendiente.
         v_mig_ctaseguro_libreta.ncarga := v_ncarga;
         v_mig_ctaseguro_libreta.cestmig := 1;
         v_mig_ctaseguro_libreta.mig_pk := v_mig_ctaseguro.mig_pk;
         v_mig_ctaseguro_libreta.mig_fk := v_mig_ctaseguro.mig_fk;
         v_mig_ctaseguro_libreta.nmovimi := vn_mov;
         v_mig_ctaseguro_libreta.fcontab := v_mig_ctaseguro.fcontab;
         v_mig_ctaseguro_libreta.sseguro := 0;
         v_mig_ctaseguro_libreta.nnumlin := v_mig_ctaseguro.nnumlin;
         v_mig_ctaseguro_libreta.ccapgar := vccapgar;
         v_mig_ctaseguro_libreta.ccapfal := vccapfal;
         v_mig_ctaseguro_libreta.igasext := vigasext;
         v_mig_ctaseguro_libreta.igasint := vigasint;
         vtraza := 2030;

         INSERT INTO mig_ctaseguro
              VALUES v_mig_ctaseguro
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 1, v_mig_ctaseguro.mig_pk);

         INSERT INTO mig_ctaseguro_libreta
              VALUES v_mig_ctaseguro_libreta
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 2, v_mig_ctaseguro.mig_pk);

         vtraza := 2040;
---- jlb 21/02/2011          END LOOP;
      --    Caso de participaciones
      END IF;
*/
      UPDATE int_rga
         SET ncarga = v_ncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1620;
      x.ncarga := v_ncarga;
      --   COMMIT;
      --TRASPASAMOS A LAS REALES
      pac_mig_axis.p_migra_cargas(x.nlinea, 'M', x.ncarga, 'DEL');
      vtraza := 1630;

      --Cargamos las SEG para la póliza (ncarga)
      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 1640;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            p_deserror := 'Error al ¡nsertar en linea';
            RAISE errdatos;
         END IF;

         vtraza := 1650;
         vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 151840, reg.incid);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            p_deserror := 'Error al ¡nsertar en linea errs';
            RAISE errdatos;
         END IF;

         p_deserror := 'Fallo al cargar el recibo';
         vcerror := 108953;
         RAISE errdatos;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         vn_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         vn_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, NVL(vcerror, vtraza),
                                     NVL(p_deserror, vtraza));
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := x.proceso || '-' || x.nlinea || ' (f_crea_ctaseguro traza=' || vtraza
                       || ') ' || SQLCODE || ' ' || SQLERRM;
         -- Bug 16324. FAL. 26/10/2010. Registrar linea y error en caso de error
         vn_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         vn_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_crea_ctaseguro;   -- f_crea_ctaseguro

   /*************************************************************************
      Funcion que inserta una renta en pagosrenta
      param  x in out: Registro tipo int_rga.
      param  p_n_seg in : Es el sseguro de lap´póliza
      param pimporte in : Importe de la renta
      devuelve 0 para correcto o número error.
      *************************************************************************/
   FUNCTION f_crea_renta(
      x IN OUT int_rga%ROWTYPE,
      p_n_seg IN NUMBER,
      pimporte NUMBER,
      psrecren OUT NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vn_mov         NUMBER;
      errdatos       EXCEPTION;
      vmot           NUMBER;
      p_deserror     VARCHAR2(200);
      v_ncarga       NUMBER;
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
      v_ncarga := f_next_carga;
      vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Rentas', v_seq);
      vtraza := 1520;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

-------------------- INICI ---------------------
      vtraza := 1525;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SEGUROS', 0);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_ASEGURADOS', 1);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_PAGOSRENTA', 2);

      vtraza := 1530;
      v_mig_pag.mig_pk := v_ncarga || '-' || x.poliza_participe || '-' || x.producto;
      v_mig_pag.mig_fk := v_ncarga || '-' || x.poliza_participe || '-' || x.producto;
      v_mig_pag.sseguro := 0;
      vtraza := 3;
      v_mig_pag.ffecefe := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr');
      vtraza := 1545;

      IF v_mig_pag.ffecefe IS NULL THEN
         p_deserror := 'Fecha de inicio de periodo nula';
         vcerror := 1000135;
         RAISE errdatos;
      END IF;

      v_mig_pag.ffecpag := v_mig_pag.ffecefe;
      v_mig_pag.isinret := pimporte + x.imp_presta_pens_retenciones;
      vtraza := 4;
      v_mig_pag.pretenc := 0;   --JRH IMP De momento
      v_mig_pag.iretenc := x.imp_presta_pens_retenciones;
      v_mig_pag.ibase := pimporte;
      vtraza := 5;
      v_mig_pag.iconret := v_mig_pag.isinret - v_mig_pag.iretenc;
      v_mig_pag.ncarga := v_ncarga;
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

      SELECT v_ncarga ncarga, -4 cestmig, v_mig_pag.mig_pk mig_pk, v_mig_pag.mig_pk mig_fk,
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

      SELECT v_ncarga ncarga, -4 cestmig, v_mig_pag.mig_pk mig_pk, v_mig_pag.mig_pk mig_fk,
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
           VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

      vtraza := 1585;

      INSERT INTO mig_asegurados
           VALUES v_mig_ase
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 1, v_mig_ase.mig_pk);

      vtraza := 1590;

      INSERT INTO mig_pagosrenta
           VALUES v_mig_pag
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 2, v_mig_pag.mig_pk);

      UPDATE int_rga
         SET ncarga = v_ncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1620;
      x.ncarga := v_ncarga;
      --   COMMIT;
      --TRASPASAMOS A LAS REALES
      pac_mig_axis.p_migra_cargas(x.nlinea, 'M', x.ncarga, 'DEL');
      vtraza := 1630;

      --Cargamos las SEG para la póliza (ncarga)
      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 1640;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
                           AND c.srecren = pagosrenta.srecren);

      --Recuperamos la renta generada no pagada
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         vn_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_crea_renta;   -- f_crea_renta

   /*************************************************************************
      Funcion que crea un siniestro en sin_siniestro --a partir del registro tipo int_rga. Es un siniestro con un pago.
      Si ppagado es true lo abre paga y cierra (siniestros de ahorro), sii n olo deja en valoración abierto.
      param  x in out: Registro tipo int_rga.
      param  p_n_seg in : Es el sseguro de lap´póliza
      param p_tipo_oper : Rescate,..
      param pimporte in : Importe
      param psidepag  out  : Pago de siniestro
      ppagado BOOLEAN in default true: Indica si el siniestro está pagado cerrado.
      devuelve 0 para correcto o número error.
      *************************************************************************/
   FUNCTION f_crea_siniestro(
      x IN OUT int_rga%ROWTYPE,
      p_n_seg IN NUMBER,
      p_causin IN NUMBER,
      p_motsin IN NUMBER,
      pimporte IN NUMBER,
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
      v_ncarga       NUMBER;
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
      v_ncarga := f_next_carga;
      vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Ctaseguro', v_seq);
      vtraza := 1520;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

-------------------- INICI ---------------------
      vtraza := 1525;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SEGUROS', 0);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_PERSONAS', 1);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_SINIESTRO', 2);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_MOVSINIESTRO', 3);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITACION', 4);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_MOVIMIENTO', 5);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_RESERVA', 6);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_PAGO_GAR', 7);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_PAGO', 8);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_MOVPAGO', 9);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_DEST', 10);

      vtraza := 1530;
      v_mig_siniestros.ncarga := v_ncarga;
      v_mig_siniestros.cestmig := 1;
      v_mig_siniestros.mig_pk := v_ncarga || '-' || x.poliza_participe || '-' || x.producto;
      v_mig_siniestros.mig_fk := v_mig_siniestros.mig_pk;
      v_mig_siniestros.nsinies := 0;   --JRH IMPx.sinieann || x.sinienum;
      v_mig_siniestros.sseguro := 0;
      v_mig_siniestros.nriesgo := 1;
      v_mig_siniestros.nmovimi := 0;

      IF TO_DATE(x.fec_anulacion, 'dd/mm/rrrr') BETWEEN TO_DATE(x.fec_inicio_periodo,
                                                                'dd/mm/rrrr')
                                                    AND TO_DATE(x.fec_fin_periodo,
                                                                'dd/mm/rrrr') THEN
         v_mig_siniestros.fsinies := NVL(TO_DATE(x.fec_anulacion, 'dd/mm/rrrr'),
                                         TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'));
      ELSE
         v_mig_siniestros.fsinies := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr');
      --JRH IMP Mirar donde viene
      END IF;

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
            AND cmotsin = p_motsin;
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

      SELECT v_ncarga ncarga, -4 cestmig, v_mig_siniestros.mig_pk mig_pk,
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

      IF p_causin = 1
         AND p_motsin IN(0, 4)
         AND x.beneficiario IS NOT NULL THEN
         --En caso de fallec. damos de alta el beneficiario JRH IMP (mirar estos motivos), o pasar por parámetro el tipo de destinatario
         v_mig_personas.ncarga := v_ncarga;
         v_mig_personas.cestmig := 1;
         v_mig_personas.mig_pk := v_mig_siniestros.mig_pk;
         v_mig_personas.idperson := 0;
         v_mig_personas.ctipide := 1;   --JRH IMP
         v_mig_personas.cestper := 0;   --JRH IMP
         v_mig_personas.cpertip := 0;
         v_mig_personas.swpubli := 0;
         v_mig_personas.tapelli1 := SUBSTR(x.beneficiario, 1, 40);
      ELSE
         SELECT v_ncarga ncarga, -4 cestmig, v_mig_siniestros.mig_pk mig_pk,
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
            AND d.sperson = p.sperson;
      --En caso de que no sea el asegurado tendríamos que ver si nos lo envían
      END IF;

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
           VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

      INSERT INTO mig_personas
           VALUES v_mig_personas
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 1, v_mig_personas.mig_pk);

      vtraza := 1590;

      INSERT INTO mig_sin_siniestro
           VALUES v_mig_siniestros
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 2, v_mig_siniestros.mig_pk);

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
      v_mig_movsin.ncarga := v_ncarga;
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
           VALUES (0, v_ncarga, 3, v_mig_movsin.mig_pk);

      --COBRO
      IF ppagado THEN
         vtraza := 1600;
         v_cont_movsin := v_cont_movsin + 1;
         v_mig_movsin := NULL;
         v_mig_movsin.ncarga := v_ncarga;
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
              VALUES (0, v_ncarga, 3, v_mig_movsin.mig_pk);
      END IF;

/*********************************************************
*********************************************************
Tramitacion
*********************************************************
*********************************************************
*********************************************************/
      v_mig_tramit := NULL;
      v_mig_tramit.ncarga := v_ncarga;
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
           VALUES (0, v_ncarga, 4, v_mig_tramit.mig_pk);

/*********************************************************
*********************************************************
MIG_SIN_TRAMITA_MOVIMIENTO
*********************************************************
*********************************************************
*********************************************************/
      v_mig_tramit_mov := NULL;
      v_mig_tramit_mov.ncarga := v_ncarga;
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
           VALUES (0, v_ncarga, 5, v_mig_tramit_mov.mig_pk);

      IF ppagado THEN
--Siniestro cerrado
         vtraza := 1650;
         v_mig_tramit_mov := NULL;
         v_mig_tramit_mov.ncarga := v_ncarga;
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
              VALUES (0, v_ncarga, 5, v_mig_tramit_mov.mig_pk);
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
      v_mig_tramit_res.ncarga := v_ncarga;
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
      v_mig_tramit_res.ireserva := pimporte + NVL(x.imp_presta_pens_retenciones, 0);
      v_mig_tramit_res.ipago := NULL;
      v_mig_tramit_res.iingreso := NULL;
      v_mig_tramit_res.irecobro := NULL;
      v_mig_tramit_res.icaprie := pimporte + NVL(x.imp_presta_pens_retenciones, 0);
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
           VALUES (0, v_ncarga, 6, v_mig_tramit_res.mig_pk);

      IF ppagado THEN
--Si se ha pagado
         v_nmov_res := v_nmov_res + 1;
         v_mig_tramit_res := NULL;
         v_mig_tramit_res.ncarga := v_ncarga;
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
         v_mig_tramit_res.ipago := pimporte + NVL(x.imp_presta_pens_retenciones, 0);
         v_mig_tramit_res.iingreso := NULL;
         v_mig_tramit_res.irecobro := NULL;
         v_mig_tramit_res.icaprie := pimporte + NVL(x.imp_presta_pens_retenciones, 0);
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
              VALUES (0, v_ncarga, 6, v_mig_tramit_res.mig_pk);

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
         v_mig_tramit_pago_g.ncarga := v_ncarga;
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
         v_mig_tramit_pago_g.isinret := pimporte + NVL(x.imp_presta_pens_retenciones, 0);
         --JRH IMP De momento un parámetro
         v_mig_tramit_pago_g.iretenc := NVL(x.imp_presta_pens_retenciones, 0);
         --JRH IMP Mirar donde viene
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
              VALUES (0, v_ncarga, 7, v_mig_tramit_pago_g.mig_pk);

/*********************************************************
*********************************************************
 mig_sin_tramita_pago
*********************************************************
*********************************************************
*********************************************************/
--si se ha pagado
         v_mig_tramit_pago := NULL;
         v_mig_tramit_pago.ncarga := v_ncarga;
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
         v_mig_tramit_pago.isinret := pimporte + NVL(x.imp_presta_pens_retenciones, 0);
         --JRH IMP De momento parámetro
         v_mig_tramit_pago.iretenc := x.imp_presta_pens_retenciones;   --JRH IMP ?
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
              VALUES (0, v_ncarga, 8, v_mig_tramit_pago.mig_pk);

/*********************************************************
*********************************************************
 mig_sin_tramita_movpago
*********************************************************
*********************************************************
*********************************************************/
         v_nmov_pago := v_nmov_pago + 1;
         v_mig_tramit_movpago := NULL;
         v_mig_tramit_movpago.ncarga := v_ncarga;
         v_mig_tramit_movpago.cestmig := 1;
         v_mig_tramit_movpago.mig_pk := v_mig_siniestros.mig_pk || ':' || v_mig_tramit.ntramit
                                        || ':' || v_mig_tramit_pago_g.sidepag || ':'
                                        || v_nmov_pago;
         v_mig_tramit_movpago.mig_fk := v_mig_tramit_pago.mig_pk;
         --v_mig_tramit.mig_pk || ':'
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
              VALUES (0, v_ncarga, 9, v_mig_tramit_movpago.mig_pk);

         vtraza := 1760;
--Si se paga
         v_nmov_pago := v_nmov_pago + 1;
         v_mig_tramit_movpago := NULL;
         v_mig_tramit_movpago.ncarga := v_ncarga;
         v_mig_tramit_movpago.cestmig := 1;
         v_mig_tramit_movpago.mig_pk := v_mig_siniestros.mig_pk || ':' || v_mig_tramit.ntramit
                                        || ':' || v_mig_tramit_pago_g.sidepag || ':'
                                        || v_nmov_pago;
         v_mig_tramit_movpago.mig_fk := v_mig_tramit_pago.mig_pk;
         --v_mig_tramit.mig_pk || ':'
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
              VALUES (0, v_ncarga, 9, v_mig_tramit_movpago.mig_pk);
      END IF;

      IF NVL(v_mig_personas.idperson, 0) <> 0 THEN
         v_mig_tramit_dest := NULL;
         v_mig_tramit_dest.ncarga := v_ncarga;
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
              VALUES (0, v_ncarga, 10, v_mig_tramit_dest.mig_pk);
      END IF;

/*********************************************************
*********************************************************
Generación
*********************************************************
*********************************************************
*********************************************************/
      UPDATE int_rga
         SET ncarga = v_ncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1730;
      x.ncarga := v_ncarga;
      --   COMMIT;
      --TRASPASAMOS A LAS REALES
      pac_mig_axis.p_migra_cargas(x.nlinea, 'M', x.ncarga, 'DEL');
      vtraza := 1740;

      --Cargamos las SEG para la póliza (ncarga)
      FOR reg IN (SELECT *
                    FROM mig_logs_axis
                   WHERE ncarga = x.ncarga
                     AND tipo = 'E') LOOP   --Miramos si ha habido algún error y lo informamos.
         vtraza := 1640;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         vn_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_crea_siniestro;

   /*************************************************************************
      Funcion que crea un siniestro en sin_siniestro --a partir del registro tipo int_rga. Es un siniestro con un pago.
      Si ppagado es true lo abre paga y cierra (siniestros de ahorro), sii n olo deja en valoración abierto.
      param  x in out: Registro tipo int_rga.
      param  p_n_seg in : Es el sseguro de lap´póliza
      param p_tipo_oper : Rescate,..
      param pimporte in : Importe
      param psidepag  out  : Pago de siniestro
      ppagado BOOLEAN in default true: Indica si el siniestro está pagado cerrado.
      devuelve 0 para correcto o número error.
      *************************************************************************/
   FUNCTION f_crea_siniestro_generales(
      x IN OUT int_rga%ROWTYPE,
      p_n_seg IN NUMBER,
      p_causin IN NUMBER,
      p_motsin IN NUMBER,
      pimporte IN NUMBER,
      ppagado IN BOOLEAN DEFAULT TRUE,
      pctipcap IN NUMBER DEFAULT 0)
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
      v_ncarga       NUMBER;
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
      cont           NUMBER := 0;
      aux_cerrados   NUMBER := 0;
      cont_cerrados  NUMBER := 0;
      v_pagado       NUMBER := 0;
      v_nsinies      NUMBER;
      v_fsinies      DATE;
      v_sperson      NUMBER;
      v_cagente      NUMBER;
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

      --Empezamos a cear tantos siniestros como tengamos indicados
      IF NVL(x.num_siniestros, 0) <> 0 THEN
         LOOP
            --Inicialización
            cont_cerrados := aux_cerrados;
            v_cont_movsin := 0;

            IF cont = 0 THEN   --La primera vez
               vtraza := 1505;
               v_ncarga := f_next_carga;
               vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Siniestro',
                                              v_seq);
               vtraza := 1520;

               INSERT INTO mig_cargas
                           (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                    VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

-------------------- INICI ---------------------
               vtraza := 1525;

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_SEGUROS', 0);

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_PERSONAS', 1);

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_SINIESTRO', 2);

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_MOVSINIESTRO', 3);

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITACION', 4);

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_MOVIMIENTO', 5);

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_RESERVA', 6);

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_PAGO_GAR', 7);

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_PAGO', 8);

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_MOVPAGO', 9);

               INSERT INTO mig_cargas_tab_mig
                           (ncarga, tab_org, tab_des, ntab)
                    VALUES (v_ncarga, 'INT_RGA', 'MIG_SIN_TRAMITA_DEST', 10);
            END IF;

            vtraza := 1500;
            v_mig_siniestros.ncarga := v_ncarga;
            v_mig_siniestros.cestmig := 1;
            v_mig_siniestros.mig_pk := v_ncarga || '-' || x.poliza_participe || '-'
                                       || x.producto || '-' || cont;
            v_mig_siniestros.mig_fk := v_mig_siniestros.mig_pk;
            v_mig_siniestros.nsinies := 0;   --JRH IMPx.sinieann || x.sinienum;
            v_mig_siniestros.sseguro := 0;
            v_mig_siniestros.nriesgo := 1;
            v_mig_siniestros.nmovimi := 0;

            IF TO_DATE(x.fec_anulacion, 'dd/mm/rrrr') BETWEEN TO_DATE(x.fec_inicio_periodo,
                                                                      'dd/mm/rrrr')
                                                          AND TO_DATE(x.fec_fin_periodo,
                                                                      'dd/mm/rrrr') THEN
               v_mig_siniestros.fsinies := NVL(TO_DATE(x.fec_anulacion, 'dd/mm/rrrr'),
                                               TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'));
            ELSE
               v_mig_siniestros.fsinies := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr');
            --JRH IMP Mirar donde viene
            END IF;

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
                  AND cmotsin = p_motsin;
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
            vtraza := 1510;
            -- Necesitamos informar mig_seguros para join con mig_ctaseguro
            vtraza := 1410;

            SELECT v_ncarga ncarga, -4 cestmig, v_mig_siniestros.mig_pk mig_pk,
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

            vtraza := 1420;

            IF p_causin = 1
               AND p_motsin IN(0, 4)
               AND x.beneficiario IS NOT NULL THEN
               --En caso de fallec. damos de alta el beneficiario JRH IMP (mirar estos motivos), o pasar por parámetro el tipo de destinatario
               v_mig_personas.ncarga := v_ncarga;
               v_mig_personas.cestmig := 1;
               v_mig_personas.mig_pk := v_mig_siniestros.mig_pk;
               v_mig_personas.idperson := 0;
               v_mig_personas.ctipide := 1;   --JRH IMP
               v_mig_personas.cestper := 0;   --JRH IMP
               v_mig_personas.cpertip := 0;
               v_mig_personas.swpubli := 0;
               v_mig_personas.tapelli1 := SUBSTR(x.beneficiario, 1, 40);
            ELSE
               SELECT v_ncarga ncarga, -4 cestmig, v_mig_siniestros.mig_pk mig_pk,
                      p.sperson, p.ctipide,
                      p.cestper, 1, p.swpubli,
                      d.tapelli1
                 INTO v_mig_personas.ncarga, v_mig_personas.cestmig, v_mig_personas.mig_pk,
                      v_mig_personas.idperson, v_mig_personas.ctipide,
                      v_mig_personas.cestper, v_mig_personas.cpertip, v_mig_personas.swpubli,
                      v_mig_personas.tapelli1
                 FROM asegurados a, per_personas p, per_detper d
                WHERE a.sseguro = p_n_seg
                  AND a.norden = 1
                  AND p.sperson = a.sperson
                  AND d.cagente = ff_agente_cpervisio(v_mig_seg.cagente)
                  AND d.sperson = p.sperson;
            --En caso de que no sea el asegurado tendríamos que ver si nos lo envían
            END IF;

            vtraza := 1435;

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

            vtraza := 1440;

            INSERT INTO mig_seguros
                 VALUES v_mig_seg
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

            INSERT INTO mig_personas
                 VALUES v_mig_personas
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 1, v_mig_personas.mig_pk);

            v_mig_siniestros.nmovimi := vn_mov;

            INSERT INTO mig_sin_siniestro
                 VALUES v_mig_siniestros
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 2, v_mig_siniestros.mig_pk);

/*********************************************************
*********************************************************
mig_sin_movsiniestro
*********************************************************
*********************************************************
*********************************************************/                                                                                                                                                                                                                                                                                                  --ALTA
            vtraza := 1600;
            v_cont_movsin := v_cont_movsin + 1;   ----Será 1
            v_mig_movsin := NULL;
            v_mig_movsin.ncarga := v_ncarga;
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
                 VALUES (0, v_ncarga, 3, v_mig_movsin.mig_pk);

            --Comprobamos antes de darlo por cerrado :
              --Si no hay ningún siniestro pendiente y se han de cerrar siniestros
              --entonces este es el primer siniestro pendiente y por tanto el que se ha de cerrar.
            IF NVL(x.num_siniestros_pendientes, 0) = 0
               AND(NVL(x.num_siniestros_cerrados, 0) - NVL(cont_cerrados, 0)) <> 0 THEN
               aux_cerrados := aux_cerrados + 1;
               --Descontamos uno a cerrar ya que ya lo hemos cerrado
               vtraza := 1620;
               v_cont_movsin := v_cont_movsin + 1;
               v_mig_movsin := NULL;
               v_mig_movsin.ncarga := v_ncarga;
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
               vtraza := 1630;

               INSERT INTO mig_sin_movsiniestro
                    VALUES v_mig_movsin
                 RETURNING ROWID
                      INTO v_rowid;

               INSERT INTO mig_pk_emp_mig
                    VALUES (0, v_ncarga, 3, v_mig_movsin.mig_pk);
            END IF;

/*********************************************************
*********************************************************
Tramitacion
*********************************************************
*********************************************************
*********************************************************/
            v_mig_tramit := NULL;
            v_mig_tramit.ncarga := v_ncarga;
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
            vtraza := 1640;

            INSERT INTO mig_sin_tramitacion
                 VALUES v_mig_tramit
              RETURNING ROWID
                   INTO v_rowid;

            INSERT INTO mig_pk_emp_mig
                 VALUES (0, v_ncarga, 4, v_mig_tramit.mig_pk);

/*********************************************************
*********************************************************
MIG_SIN_TRAMITA_MOVIMIENTO
*********************************************************
*********************************************************
*********************************************************/
            v_mig_tramit_mov := NULL;
            v_mig_tramit_mov.ncarga := v_ncarga;
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
                 VALUES (0, v_ncarga, 5, v_mig_tramit_mov.mig_pk);

            --Comprobamos antes de darlo por cerrado :
            --Si no hay ningún siniestro pendiente y se han de cerrar siniestros
            --entonces este es el primer siniestro pendiente y por tanto el que se ha de cerrar.
            IF NVL(x.num_siniestros_pendientes, 0) = 0
               AND(NVL(x.num_siniestros_cerrados, 0) - NVL(cont_cerrados, 0)) <> 0 THEN
               vtraza := 1650;
               v_mig_tramit_mov := NULL;
               v_mig_tramit_mov.ncarga := v_ncarga;
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
                    VALUES (0, v_ncarga, 5, v_mig_tramit_mov.mig_pk);
            END IF;

            --Si no hay siniestros pendientes y viene importe de pago consideramos que este es el primer
            --siniestro pendiente y le creamos el pago si no se lo hemos creado a algun siniestro anterior en el loop
            IF NVL(x.num_siniestros_pendientes, 0) = 0
               AND NVL(x.importe_pagos, 0) <> 0
               AND v_pagado = 0 THEN
               v_pagado := 1;

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
               v_mig_tramit_res.ncarga := v_ncarga;
               v_mig_tramit_res.cestmig := 1;
               v_mig_tramit_res.mig_pk := v_mig_siniestros.mig_pk || ':'
                                          || v_mig_tramit.ntramit || ':' || 1 || ':'
                                          || v_nmov_res;
               v_mig_tramit_res.mig_fk := v_mig_tramit.mig_pk;
               v_mig_tramit_res.nsinies := 0;
               v_mig_tramit_res.ntramit := v_mig_tramit.ntramit;
               v_mig_tramit_res.ctipres := 1;
               v_mig_tramit_res.nmovres := v_nmov_res;
               v_mig_tramit_res.cgarant := v_cgarant;
               v_mig_tramit_res.ccalres := 0;
               v_mig_tramit_res.fmovres := v_mig_siniestros.fsinies;   --JHR ??
               v_mig_tramit_res.cmonres := 'EUR';
               v_mig_tramit_res.ireserva := pimporte;
               v_mig_tramit_res.ipago := NULL;
               v_mig_tramit_res.iingreso := NULL;
               v_mig_tramit_res.irecobro := NULL;
               v_mig_tramit_res.icaprie := pimporte;
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
                    VALUES (0, v_ncarga, 6, v_mig_tramit_res.mig_pk);

               --Si tambien damos este siniestro por cerrado, cerramos la reserva
               --if (nvl(x.num_siniestros_cerrados,0)-nvl(cont_cerrados,0)) <> 0 then
               v_nmov_res := v_nmov_res + 1;
               v_mig_tramit_res := NULL;
               v_mig_tramit_res.ncarga := v_ncarga;
               v_mig_tramit_res.cestmig := 1;
               vtraza := 1690;
               v_mig_tramit_res.mig_pk := v_mig_siniestros.mig_pk || ':'
                                          || v_mig_tramit.ntramit || ':' || 1 || ':'
                                          || v_nmov_res;
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
               v_mig_tramit_res.ipago := pimporte;
               v_mig_tramit_res.iingreso := NULL;
               v_mig_tramit_res.irecobro := NULL;
               v_mig_tramit_res.icaprie := pimporte;
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
                    VALUES (0, v_ncarga, 6, v_mig_tramit_res.mig_pk);

               -- end if;

               /*********************************************************
*********************************************************
 v_mig_tramit_pago_g
*********************************************************
*********************************************************
*********************************************************/
               vtraza := 1720;
               v_sidepag := v_sidepag + 1;
               v_mig_tramit_pago_g := NULL;
               v_mig_tramit_pago_g.ncarga := v_ncarga;
               v_mig_tramit_pago_g.cestmig := 1;
               v_mig_tramit_pago_g.mig_pk := v_mig_siniestros.mig_pk || ':'
                                             || v_mig_tramit.ntramit || ':' || 1 || ':'
                                             || v_nmov_res || ':' || v_sidepag;
               --NSINIES+NTRAMIT
               v_mig_tramit_pago_g.mig_fk := v_mig_siniestros.mig_pk || ':'
                                             || v_mig_tramit.ntramit || ':' || v_sidepag;
               v_mig_tramit_pago_g.sidepag := v_sidepag;
               v_mig_tramit_pago_g.ctipres := 1;
               v_mig_tramit_pago_g.norden := v_sidepag;
               v_mig_tramit_pago_g.nmovres := v_nmov_res;
               v_mig_tramit_pago_g.cgarant := v_cgarant;
               v_mig_tramit_pago_g.fperini := NULL;
               v_mig_tramit_pago_g.fperfin := NULL;
               v_mig_tramit_pago_g.cmonres := NULL;
               v_mig_tramit_pago_g.isinret := pimporte;   --JRH IMP De momento un parámetro
               v_mig_tramit_pago_g.iretenc := 0;   --JRH IMP Mirar donde viene
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
                    VALUES (0, v_ncarga, 7, v_mig_tramit_pago_g.mig_pk);

/*********************************************************
*********************************************************
 mig_sin_tramita_pago
*********************************************************
*********************************************************
*********************************************************/
--si se ha pagado
               v_mig_tramit_pago := NULL;
               v_mig_tramit_pago.ncarga := v_ncarga;
               v_mig_tramit_pago.cestmig := 1;
               v_mig_tramit_pago.mig_pk := v_mig_siniestros.mig_pk || ':'
                                           || v_mig_tramit.ntramit || ':'
                                           || v_mig_tramit_pago_g.sidepag;
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
               v_mig_tramit_pago.isinret := pimporte + NVL(x.imp_presta_pens_retenciones, 0);
               --JRH IMP De momento parámetro
               v_mig_tramit_pago.iretenc := x.imp_presta_pens_retenciones;   --JRH IMP ?
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
                    VALUES (0, v_ncarga, 8, v_mig_tramit_pago.mig_pk);

 /*********************************************************
*********************************************************
 mig_sin_tramita_movpago
*********************************************************
*********************************************************
*********************************************************/
               v_nmov_pago := v_nmov_pago + 1;
               v_mig_tramit_movpago := NULL;
               v_mig_tramit_movpago.ncarga := v_ncarga;
               v_mig_tramit_movpago.cestmig := 1;
               v_mig_tramit_movpago.mig_pk := v_mig_siniestros.mig_pk || ':'
                                              || v_mig_tramit.ntramit || ':'
                                              || v_mig_tramit_pago_g.sidepag || ':'
                                              || v_nmov_pago;
               v_mig_tramit_movpago.mig_fk := v_mig_tramit_pago.mig_pk;
               --v_mig_tramit.mig_pk || ':'
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
                    VALUES (0, v_ncarga, 9, v_mig_tramit_movpago.mig_pk);

               vtraza := 1760;
               --Si se paga
               v_nmov_pago := v_nmov_pago + 1;
               v_mig_tramit_movpago := NULL;
               v_mig_tramit_movpago.ncarga := v_ncarga;
               v_mig_tramit_movpago.cestmig := 1;
               v_mig_tramit_movpago.mig_pk := v_mig_siniestros.mig_pk || ':'
                                              || v_mig_tramit.ntramit || ':'
                                              || v_mig_tramit_pago_g.sidepag || ':'
                                              || v_nmov_pago;
               v_mig_tramit_movpago.mig_fk := v_mig_tramit_pago.mig_pk;
               --v_mig_tramit.mig_pk || ':'
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
                    VALUES (0, v_ncarga, 9, v_mig_tramit_movpago.mig_pk);
            END IF;

            IF NVL(v_mig_personas.idperson, 0) <> 0 THEN
               v_mig_tramit_dest := NULL;
               v_mig_tramit_dest.ncarga := v_ncarga;
               v_mig_tramit_dest.cestmig := 1;
               v_mig_tramit_dest.mig_pk := v_mig_siniestros.mig_pk || ':'
                                           || v_mig_tramit.ntramit || ':' || 'D' || ':' || '1';
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
                    VALUES (0, v_ncarga, 10, v_mig_tramit_dest.mig_pk);
            END IF;

            cont := cont + 1;
            EXIT WHEN cont = x.num_siniestros;
         END LOOP;

         cont_cerrados := aux_cerrados;

/*********************************************************
*********************************************************
Generación
*********************************************************
*********************************************************
*********************************************************/
         UPDATE int_rga
            SET ncarga = v_ncarga
          WHERE proceso = x.proceso
            AND nlinea = x.nlinea;

         vtraza := 1730;
         x.ncarga := v_ncarga;
         --   COMMIT;
         --TRASPASAMOS A LAS REALES
         pac_mig_axis.p_migra_cargas(x.nlinea, 'M', x.ncarga, 'DEL');
         vtraza := 1740;

         --Cargamos las SEG para la póliza (ncarga)
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = x.ncarga
                        AND tipo = 'E') LOOP
            --Miramos si ha habido algún error y lo informamos.
            vtraza := 1640;
            vnum_err :=
               p_marcalinea
                  (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.poliza_participe,   -- Fi Bug 14888
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

         FOR rc IN (SELECT nsinies
                      FROM mig_sin_siniestro
                     WHERE ncarga = x.ncarga) LOOP
            UPDATE sin_siniestro
               SET ccompani = vccompani
             WHERE nsinies = vnsinies;
         END LOOP;

         vtraza := 1900;
      END IF;

/*******************************************************
 *******************************************************
 *******************************************************/
      IF TO_DATE(x.fec_anulacion, 'dd/mm/rrrr') BETWEEN TO_DATE(x.fec_inicio_periodo,
                                                                'dd/mm/rrrr')
                                                    AND TO_DATE(x.fec_fin_periodo,
                                                                'dd/mm/rrrr') THEN
         v_fsinies := NVL(TO_DATE(x.fec_anulacion, 'dd/mm/rrrr'),
                          TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'));
      ELSE
         v_fsinies := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr');
      --JRH IMP Mirar donde viene
      END IF;

      IF v_fsinies IS NULL THEN
         p_deserror := 'Fecha de inicio de periodo nula';
         vcerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 2000;

      --Si viene un pago y no lo hemos asignado a ningún siniestro, se busca el primer siniestro pendiente y se le asigna
      IF NVL(pimporte, 0) <> 0
         AND v_pagado = 0 THEN
         --Buscamos el primer siniestro pendiente
         SELECT MIN(s.nsinies)
           INTO v_nsinies
           FROM sin_siniestro s, sin_movsiniestro sm
          WHERE ccausin = p_causin
            AND cmotsin = p_motsin
            AND sseguro = p_n_seg
            AND sm.nsinies = s.nsinies
            AND sm.nmovsin = (SELECT MAX(nmovsin)
                                FROM sin_movsiniestro sm2
                               WHERE sm2.nsinies = sm.nsinies)
            AND cestsin IN(0, 4);

         IF v_nsinies IS NULL THEN
            /*Buscamos el último siniestro cerrado y lo reabrimos*/
            SELECT MAX(s.nsinies)
              INTO v_nsinies
              FROM sin_siniestro s, sin_movsiniestro sm
             WHERE ccausin = p_causin
               AND cmotsin = p_motsin
               AND sseguro = p_n_seg
               AND sm.nsinies = s.nsinies
               AND sm.nmovsin = (SELECT MAX(nmovsin)
                                   FROM sin_movsiniestro sm2
                                  WHERE sm2.nsinies = sm.nsinies)
               AND cestsin = 1;

            IF v_nsinies IS NULL THEN
               p_deserror := 'Fallo al dar por cobrado el siniestro';
               vcerror := 108953;
               RAISE errdatos;
            END IF;

            SELECT NVL(MAX(nmovsin), 0) + 1
              INTO v_cont_movsin
              FROM sin_movsiniestro sm
             WHERE sm.nsinies = v_nsinies;

            INSERT INTO sin_movsiniestro
                        (nsinies, nmovsin, cestsin, festsin, ccauest, cunitra, ctramitad,
                         cusualt, falta)
                 VALUES (v_nsinies, v_cont_movsin, 4, v_fsinies, NULL, '0', '0',
                         f_user, f_sysdate);
         END IF;

         vtraza := 2100;

         --Info del siniestro
         /*SELECT fsinies
           INTO v_fsinies
           FROM sin_siniestro s
          WHERE s.nsinies = v_nsinies;*/
         SELECT cgarant, cagente
           INTO v_cgarant, v_cagente
           FROM garanpro g, seguros s
          WHERE g.sproduc = s.sproduc
            AND s.sseguro = p_n_seg
            AND ROWNUM = 1;

         --Creamos el movimiento de reserva
         SELECT NVL(MAX(nmovres), 0) + 1
           INTO v_nmov_res
           FROM sin_tramita_reserva st
          WHERE nsinies = v_nsinies;

         --Creamos el primer movimiento de la reserva
         INSERT INTO sin_tramita_reserva
                     (nsinies, ntramit, ctipres, nmovres, cgarant, ccalres, fmovres, cmonres,
                      ireserva, ipago, icaprie, cusualt, falta)
              VALUES (v_nsinies, 0, 1, v_nmov_res, v_cgarant, 0, v_fsinies, 'EUR',
                      pimporte, NULL, pimporte, f_user, f_sysdate);

         vtraza := 2200;

         --Creamos el primer movimiento de pago de la reserva
         SELECT sidepag.NEXTVAL
           INTO v_sidepag
           FROM DUAL;

         v_nmov_res := v_nmov_res + 1;

         INSERT INTO sin_tramita_reserva
                     (nsinies, ntramit, ctipres, nmovres, cgarant, ccalres, fmovres, cmonres,
                      ireserva, ipago, icaprie, cusualt, falta, sidepag)
              VALUES (v_nsinies, 0, 1, v_nmov_res, v_cgarant, 0, v_fsinies, 'EUR',
                      0, pimporte, pimporte, f_user, f_sysdate, v_sidepag);

         vtraza := 2300;

         SELECT p.sperson
           INTO v_sperson
           FROM asegurados a, per_personas p, per_detper d
          WHERE a.sseguro = p_n_seg
            AND a.norden = 1
            AND p.sperson = a.sperson
            AND d.cagente = ff_agente_cpervisio(v_cagente)
            AND d.sperson = p.sperson;

         --Creamos el pago
         INSERT INTO sin_tramita_pago
                     (sidepag, nsinies, ntramit, ctipdes, ctippag, cconpag, ccauind, cforpag,
                      fordpag, isinret, iretenc, cusualt, falta, sperson)
              VALUES (v_sidepag, v_nsinies, 0, 1, 2, 1, 0, 1,
                      v_fsinies, pimporte, NULL, f_user, f_sysdate, v_sperson);

         INSERT INTO sin_tramita_pago_gar
                     (sidepag, ctipres, nmovres, cgarant, isinret, iretenc, iiva, ifranq,
                      pretenc, cusualt, falta, norden)
              VALUES (v_sidepag, 1, v_nmov_res, v_cgarant, pimporte, 0, 0, 0,
                      0, f_user, f_sysdate, 1);

         vtraza := 2400;

         INSERT INTO sin_tramita_movpago
                     (sidepag, nmovpag, cestpag, fefepag, cestval, cusualt, falta)
              VALUES (v_sidepag, 1, 0, v_fsinies, 0, f_user, f_sysdate);

         --Movimiento de pago
         INSERT INTO sin_tramita_movpago
                     (sidepag, nmovpag, cestpag, fefepag, cestval, cusualt, falta)
              VALUES (v_sidepag, 2, 1, v_fsinies, 1, f_user, f_sysdate);
      END IF;

      vtraza := 3000;

/*******************************************************
 *******************************************************
 *******************************************************/
--Cerramos los siguientes siniestros pendientes, si queda alguno por cerrar
      IF NVL(x.num_siniestros_cerrados, 0) - NVL(cont_cerrados, 0) <> 0 THEN
         LOOP
            cont_cerrados := cont_cerrados + 1;

            --Buscamos el primer siniestro pendiente
            SELECT MIN(s.nsinies)
              INTO v_nsinies
              FROM sin_siniestro s, sin_movsiniestro sm
             WHERE ccausin = p_causin
               AND cmotsin = p_motsin
               AND sseguro = p_n_seg
               AND sm.nsinies = s.nsinies
               AND sm.nmovsin = (SELECT MAX(nmovsin)
                                   FROM sin_movsiniestro sm2
                                  WHERE sm2.nsinies = sm.nsinies)
               AND cestsin IN(0, 4);

            IF v_nsinies IS NULL THEN
               p_deserror := 'Fallo al cerrar todos los siniestros';
               EXIT;   -- salimos ya no quedan mas
            -- vcerror := 108953;
             --RAISE errdatos;
            ELSE
               vtraza := 3100;

               SELECT NVL(MAX(nmovsin), 0) + 1
                 INTO v_cont_movsin
                 FROM sin_movsiniestro sm
                WHERE sm.nsinies = v_nsinies;

               INSERT INTO sin_movsiniestro
                           (nsinies, nmovsin, cestsin, festsin, ccauest, cunitra, ctramitad,
                            cusualt, falta)
                    VALUES (v_nsinies, v_cont_movsin, 1, v_fsinies, NULL, '0', '0',
                            f_user, f_sysdate);

               vtraza := 3200;
            END IF;

            EXIT WHEN x.num_siniestros_cerrados = cont_cerrados;
         END LOOP;
      END IF;

      vtraza := 4000;
      /*vtraza := 3000;

      IF v_pagado THEN -- no hace falta ctaseguro
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
      END IF;*/
      --vtraza := 1820;
      RETURN 0;
   EXCEPTION
      WHEN errdatos THEN
         --rollback;
         vn_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         vn_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, vcerror, p_deserror);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := x.proceso || '-' || x.nlinea || ' (traza=' || vtraza || ') ' || SQLCODE
                       || ' ' || SQLERRM;
         -- Bug 16324. FAL. 26/10/2010. Registrar linea y error en caso de error
         vn_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         vn_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_crea_siniestro_generales;

/*************************************************************************
      Funcion que crea una renta a partir del registro tipo int_rga. Análoga a alta recibos.
      param  x in out: Registro tipo int_rga.
      param  p_deserror in out: Descripcción del error.
      devuelve 0 para correcto o número error.
      *************************************************************************/
   FUNCTION f_alta_rentas(x IN OUT int_rga%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.f_alta_rentas';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      n_seg          seguros.sseguro%TYPE;
      n_csituac      seguros.csituac%TYPE;
      n_pro          seguros.sproduc%TYPE;
      n_aux          NUMBER;
      n_mov          movseguro.nmovimi%TYPE;
      d_aux          DATE;
      n_perest       esttomadores.sperson%TYPE;
      n_cagente      seguros.cagente%TYPE;
      b_warning      BOOLEAN;
      v_deswarning   VARCHAR2(1000);
      v_poliza_rga   VARCHAR2(1000);
      v_sproduc      productos.sproduc%TYPE;
      v_cforpag      seguros.cforpag%TYPE;
      v_prima        NUMBER := 0;
       --v_impreal      NUMBER := 0;
      -- v_capital      NUMBER := 0;
      v_comi         NUMBER := 0;
      --Recibo
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      vnum_err       NUMBER;
      v_rowid        ROWID;
      v_i            BOOLEAN := FALSE;
      vsrecren       NUMBER;
      vimporterenta  NUMBER;
      vsiniestro     NUMBER;
      vsidepag       NUMBER;
      vcmotsin       NUMBER;
      vccausin       NUMBER;
   BEGIN
      IF NVL(x.imp_presta_vida_rentas, 0) = 0
         AND NVL(x.imp_presta_pens_rent_financie, 0) = 0
         AND NVL(x.imp_presta_pens_rent_asegurad, 0) = 0 THEN
         --Hacerlo para todos los campos de rentas
         RETURN 4;
      END IF;

      --JRH IMP En principio la póliza sólo genera una de estas rentas
      --Si se demuestra lo contrario habria que generar y pagar cada una de ellas por separado.
      vimporterenta := GREATEST(GREATEST(NVL(x.imp_presta_vida_rentas, 0),
                                         NVL(x.imp_presta_pens_rent_financie, 0)),
                                NVL(x.imp_presta_pens_rent_asegurad, 0));

      IF NVL(vimporterenta, 0) = 0 THEN
         RETURN 4;
      END IF;

      v_poliza_rga := x.poliza_participe;
      vtraza := 1000;
      cerror := 4;   -- ok
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;
      vtraza := 1010;

      IF LTRIM(v_poliza_rga) IS NULL THEN
         p_deserror := 'Número póliza sin informar';
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      v_sproduc := pac_cargas_rga.f_buscavalor('CRT_PRODRGA', x.producto);

      IF v_sproduc IS NULL THEN
         p_deserror := 'Producto desconocido';
         cerror := 104347;
         RAISE errdatos;
      END IF;

      vtraza := 1017;

      BEGIN
         SELECT sseguro, cforpag
           INTO n_seg, v_cforpag
           FROM seguros
          WHERE cpolcia = v_poliza_rga
            AND sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            n_seg := NULL;
      END;

      vtraza := 1018;

      IF n_seg IS NULL THEN
         p_deserror := 'Número póliza(recibo) no existe1: ' || v_poliza_rga;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vccausin := 1;
      vcmotsin := 0;

      IF UPPER(x.motivo_anulacion) LIKE '%VENC%' THEN
         vccausin := 3;
         vcmotsin := 0;
      END IF;

      IF UPPER(x.motivo_anulacion) LIKE '%RESC%' THEN
         vccausin := 4;
         vcmotsin := 0;
      END IF;

      --JRH Damos de alta la prestacion al anular la póliza
      --JRH IMP.De momento las mig no insertan en prestaren. Lo ponemos así separado para cada tipo renta.Si se quiere luego se puede unificar.
      IF TO_DATE(x.fec_anulacion, 'dd/mm/rrrr') BETWEEN TO_DATE(x.fec_inicio_periodo,
                                                                'dd/mm/rrrr')
                                                    AND TO_DATE(x.fec_fin_periodo,
                                                                'dd/mm/rrrr') THEN
         --
         IF NVL(x.imp_presta_vida_rentas, 0) <> 0 THEN   --Hemos de dar de alta la prestación.
            --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
            cerror := f_crea_siniestro(x, n_seg, vccausin, vcmotsin,
                                       NVL(x.imp_presta_vida_rentas, 0), vsidepag, FALSE, 2);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;
--         vtraza := 1100; Esto en teoria no hace falta
--         --Pagamos el siniestro (pasarle el sidepag)
--         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

         --         IF cerror <> 0 THEN
--            RAISE errdatos;
--         END IF;
         END IF;

         IF NVL(x.imp_presta_pens_rent_financie, 0) <> 0 THEN
            --Hemos de dar de alta la prestación
                  --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
            IF UPPER(x.motivo_anulacion) LIKE '%VENC%' THEN
               vcmotsin := 0;
            ELSE
               vcmotsin := 2;
            END IF;

            IF UPPER(x.motivo_anulacion) LIKE '%RESC%' THEN
               vcmotsin := 0;
            ELSE
               vcmotsin := 2;
            END IF;

            cerror := f_crea_siniestro(x, n_seg, vccausin, vcmotsin,
                                       NVL(x.imp_presta_pens_rent_financie, 0), vsidepag,
                                       FALSE, 2);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;
--         vtraza := 1100;
--         --Pagamos el siniestro (pasarle el sidepag)
--         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

         --         IF cerror <> 0 THEN
--            RAISE errdatos;
--         END IF;
         END IF;

         IF NVL(x.imp_presta_pens_rent_asegurad, 0) <> 0 THEN
            --Hemos de dar de alta la prestación
                  --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
            IF UPPER(x.motivo_anulacion) LIKE '%VENC%' THEN
               vcmotsin := 0;
            ELSE
               vcmotsin := 2;
            END IF;

            IF UPPER(x.motivo_anulacion) LIKE '%RESC%' THEN
               vcmotsin := 0;
            ELSE
               vcmotsin := 2;
            END IF;

            cerror := f_crea_siniestro(x, n_seg, vccausin, vcmotsin,
                                       NVL(x.imp_presta_pens_rent_asegurad, 0), vsidepag,
                                       FALSE, 2);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;
--         vtraza := 1100;
--         --Pagamos el siniestro (pasarle el sidepag)
--         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

         --         IF cerror <> 0 THEN
--            RAISE errdatos;
--         END IF;
         END IF;
      END IF;

      --Buscamos si existe la póliza como renta natural
      --JRH IMP Revisar si en el alta de la póliza insertamos en SEGUROS_REN o al menos en prestaren para el siniestro
      BEGIN
         SELECT cforpag
           INTO v_cforpag
           FROM seguros_ren
          WHERE sseguro = n_seg;
      EXCEPTION
         WHEN OTHERS THEN
            v_cforpag := NULL;
      END;

      IF v_cforpag IS NULL THEN   --Busquemos si la renta es una prestación
         --O Buscamos si existe la póliza como prestación
         --JRH IMP Podría haber mas de una prestacion. Tratarlo más adelante
         BEGIN
            SELECT MAX(sini.nsinies)
              INTO vsiniestro
              FROM sin_siniestro sini
             WHERE sini.sseguro = n_seg
               AND sini.fsinies = (SELECT MAX(s.fsinies)
                                     FROM sin_siniestro s
                                    WHERE s.nsinies = sini.nsinies);

            --JRH De momento, vamos a partir de que es el último siniestro el que puede llevar una prestación
            SELECT cforpag
              INTO v_cforpag
              FROM prestaren
             WHERE sseguro = n_seg
               AND nsinies = vsiniestro;
         EXCEPTION
            WHEN OTHERS THEN
               v_cforpag := NULL;
         END;
      END IF;

      vtraza := 1018;
      v_cforpag := NVL(v_cforpag, 12);   --JRH IMP De momento

      IF v_cforpag IS NULL THEN
         p_deserror := 'Número póliza(recibo) no existe como tipo renta: ' || v_poliza_rga;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1020;
      -- Generamos la ranta del periodo
      --Si no se crea pagosrenta pasar directamente a f_crea_ctaseguro
      cerror := f_crea_renta(x, n_seg, vimporterenta, vsrecren);   -- emito renta

      IF cerror <> 0 THEN
         RAISE errdatos;
      END IF;

      vtraza := 1021;
--Pagamos la renta
      cerror := f_crea_ctaseguro(x, n_seg, 4, NULL, NULL, vsrecren, NULL, NULL, FALSE);

      IF cerror <> 0 THEN
         RAISE errdatos;
      END IF;

      vtraza := 1022;

      IF NVL(v_cforpag, 0) <> 0 THEN   -- a piñón las 2 tablas
--      UPDATE seguros_ren
--         SET   --fcarpro = v_mig_rec.fvencim,
--            --fcarant = v_mig_rec.fefecto,
--            fppren = GREATEST(fppren, ADD_MONTHS(fppren, 12 / v_cforpag) + 1)
--       WHERE sseguro = n_seg;
         UPDATE seguros_ren
            SET   --fcarpro = v_mig_rec.fvencim,
               --fcarant = v_mig_rec.fefecto,
               fppren = ADD_MONTHS(TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'), 12 / v_cforpag)
          WHERE sseguro = n_seg;

--      UPDATE prestaren
--         SET   --fcarpro = v_mig_rec.fvencim,
--            --fcarant = v_mig_rec.fefecto,
--            fppren = GREATEST(fppren, ADD_MONTHS(fppren, 12 / v_cforpag) + 1)
--       WHERE sseguro = n_seg;
         UPDATE prestaren
            SET   --fcarpro = v_mig_rec.fvencim,
               --fcarant = v_mig_rec.fefecto,
               fppren = ADD_MONTHS(TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'), 12 / v_cforpag)
          WHERE sseguro = n_seg;
      END IF;

      vtraza := 1024;
      RETURN 4;   --ok
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_alta_rentas;

/*************************************************************************
      Funcion que crea un saldo
      param  x in out: Registro tipo int_rga.
      param  p_deserror in out: Descripcción del error.
      devuelve 0 para correcto o número error.
      *************************************************************************/
   FUNCTION f_alta_saldo(x IN OUT int_rga%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.f_alta_rentas';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      n_seg          seguros.sseguro%TYPE;
      n_csituac      seguros.csituac%TYPE;
      n_pro          seguros.sproduc%TYPE;
      n_aux          NUMBER;
      n_mov          movseguro.nmovimi%TYPE;
      d_aux          DATE;
      n_perest       esttomadores.sperson%TYPE;
      n_cagente      seguros.cagente%TYPE;
      b_warning      BOOLEAN;
      v_deswarning   VARCHAR2(1000);
      v_poliza_rga   VARCHAR2(1000);
      v_sproduc      productos.sproduc%TYPE;
      v_cforpag      seguros.cforpag%TYPE;
      v_prima        NUMBER := 0;
       --v_impreal      NUMBER := 0;
      -- v_capital      NUMBER := 0;
      v_comi         NUMBER := 0;
      --Recibo
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      vnum_err       NUMBER;
      v_rowid        ROWID;
      v_i            BOOLEAN := FALSE;
      vsrecren       NUMBER;
      vimportesaldo  NUMBER;
      vsiniestro     NUMBER;
   BEGIN
       --IF NVL(x.provision_matematica, 0) = 0 THEN
        --  RETURN 4;
      -- END IF;
      vimportesaldo := NVL(x.provision_matematica, 0);
      v_poliza_rga := x.poliza_participe;
      vtraza := 1000;
      cerror := 4;   -- ok
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;
      vtraza := 1010;

      IF LTRIM(v_poliza_rga) IS NULL THEN
         p_deserror := 'Número póliza sin informar';
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      v_sproduc := pac_cargas_rga.f_buscavalor('CRT_PRODRGA', x.producto);

      IF v_sproduc IS NULL THEN
         p_deserror := 'Producto desconocido';
         cerror := 104347;
         RAISE errdatos;
      END IF;

      vtraza := 1017;

      BEGIN
         SELECT sseguro, cforpag
           INTO n_seg, v_cforpag
           FROM seguros
          WHERE cpolcia = v_poliza_rga
            AND sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            n_seg := NULL;
      END;

      vtraza := 1018;

      IF n_seg IS NULL THEN
         p_deserror := 'Número póliza(recibo) no existe2: ' || v_poliza_rga;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1021;
--Pagamos la renta
      cerror := f_crea_ctaseguro(x, n_seg, 1, NULL, NULL, NULL, vimportesaldo, 0, FALSE);

      IF cerror <> 0 THEN
         RAISE errdatos;
      END IF;

      vtraza := 1022;

      --jrh 17/02/2011 PB
      IF NVL(x.importe_pb, 0) <> 0 THEN
         cerror := f_crea_ctaseguro(x, n_seg, 1, NULL, NULL, NULL, x.importe_pb, 9, FALSE);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;
      END IF;

      --jrh 17/02/2011
      vtraza := 1024;
      vtraza := 1024;
      RETURN 4;   --ok
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_alta_saldo;

/*************************************************************************
      Funcion que crea los siniestros a partir del registro tipo int_rga. Análoga a alta recibos.
      param  x in out: Registro tipo int_rga.
      param  p_deserror in out: Descripcción del error.
      devuelve 0 para correcto o número error.
      *************************************************************************/
   FUNCTION f_alta_siniestros(x IN OUT int_rga%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.f_alta_siniestros';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      n_seg          seguros.sseguro%TYPE;
      n_csituac      seguros.csituac%TYPE;
      n_pro          seguros.sproduc%TYPE;
      n_aux          NUMBER;
      n_mov          movseguro.nmovimi%TYPE;
      d_aux          DATE;
      n_perest       esttomadores.sperson%TYPE;
      n_cagente      seguros.cagente%TYPE;
      b_warning      BOOLEAN;
      v_deswarning   VARCHAR2(1000);
      v_poliza_rga   VARCHAR2(1000);
      v_sproduc      productos.sproduc%TYPE;
      v_cforpag      seguros.cforpag%TYPE;
      v_prima        NUMBER := 0;
       --v_impreal      NUMBER := 0;
      -- v_capital      NUMBER := 0;
      v_comi         NUMBER := 0;
      --Recibo
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      vnum_err       NUMBER;
      v_rowid        ROWID;
      v_i            BOOLEAN := FALSE;
      vsidepag       NUMBER;
   BEGIN
      IF NVL(x.imp_presta_vida_vencimientos, 0) = 0
         AND NVL(x.imp_presta_vida_rescates, 0) = 0
         AND NVL(x.traspasos_salida, 0) = 0
         AND NVL(x.traspasos_internos_sal, 0) = 0
         AND NVL(x.traspaso_salida_rga, 0) = 0
         AND NVL(x.imp_presta_pensiones_capital, 0) = 0
         AND NVL(x.imp_presta_vida_siniestros, 0) = 0
         AND NVL(x.imp_presta_pens_a_vida, 0) = 0
         AND NVL(x.imp_presta_pens_de_vida, 0) = 0
         --Bug.: 18780
         AND(x.empresa = 11
             AND(NVL(x.num_siniestros, 0) = 0
                 AND NVL(x.importe_pagos, 0) = 0
                 AND NVL(x.num_siniestros_cerrados, 0) = 0)) THEN
         RETURN 4;   -- no hay nada que tratar
      END IF;

      v_poliza_rga := x.poliza_participe;
      vtraza := 1000;
      cerror := 4;   -- ok
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;
      vtraza := 1010;

      IF LTRIM(v_poliza_rga) IS NULL THEN
         p_deserror := 'Número póliza sin informar';
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      v_sproduc := pac_cargas_rga.f_buscavalor('CRT_PRODRGA', x.producto);

      IF v_sproduc IS NULL THEN
         p_deserror := 'Producto desconocido';
         cerror := 104347;
         RAISE errdatos;
      END IF;

      vtraza := 1017;

      BEGIN
         SELECT sseguro, cforpag
           INTO n_seg, v_cforpag
           FROM seguros
          WHERE cpolcia = v_poliza_rga
            AND sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            n_seg := NULL;
      END;

      vtraza := 1018;

      IF n_seg IS NULL THEN
         p_deserror := 'Número póliza(recibo) no existe4: ' || v_poliza_rga;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1095;

      --JRH Lo ponemos todo separado para verlo de momento más claro
      IF NVL(x.imp_presta_vida_vencimientos, 0) <> 0
         AND UPPER(x.motivo_anulacion) LIKE '%VENC%' THEN
         cerror := f_crea_siniestro(x, n_seg, 3, 0, NVL(x.imp_presta_vida_vencimientos, 0),
                                    vsidepag);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;

         vtraza := 1100;
         --Pagamos el siniestro (pasarle el sidepag)
         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;
      END IF;

      -- JRH Aqui ver para que casos hay que llamar a crear siniestro y crear entonces ctaseguro
      --Por ejemplo un rescate total
      IF NVL(x.imp_presta_vida_rescates, 0) <> 0
         AND UPPER(x.motivo_anulacion) LIKE '%RESC%' THEN   --Rescate
         --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
         cerror := f_crea_siniestro(x, n_seg, 4, 0, NVL(x.imp_presta_vida_rescates, 0),
                                    vsidepag);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;

         vtraza := 1100;
         --Pagamos el siniestro (pasarle el sidepag)
         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;
      END IF;

      IF NVL(x.imp_presta_vida_rescates, 0) <> 0
         AND UPPER(x.motivo_anulacion) IS NULL THEN   --Rescate Parcial
         --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
         cerror := f_crea_siniestro(x, n_seg, 5, 0, NVL(x.imp_presta_vida_rescates, 0),
                                    vsidepag);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;

         vtraza := 1100;
         --Pagamos el siniestro (pasarle el sidepag)
         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;
      END IF;

      IF NVL(x.traspasos_salida, 0) <> 0 THEN   --Traspaso salida
         --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
         cerror := f_crea_siniestro(x, n_seg, 8, 1, NVL(x.traspasos_salida, 0), vsidepag);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;

         vtraza := 1100;
         --Pagamos el siniestro (pasarle el sidepag)
         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;
      END IF;

      IF NVL(x.traspasos_internos_sal, 0) <> 0 THEN   --Traspaso salida
         --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
         cerror := f_crea_siniestro(x, n_seg, 8, 1, NVL(x.traspasos_internos_sal, 0),
                                    vsidepag);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;

         vtraza := 1100;
         --Pagamos el siniestro (pasarle el sidepag)
         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;
      END IF;

      IF NVL(x.traspaso_salida_rga, 0) <> 0 THEN   --Traspaso salida
         --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
         cerror := f_crea_siniestro(x, n_seg, 8, 1, NVL(x.traspaso_salida_rga, 0), vsidepag);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;

         vtraza := 1100;
         --Pagamos el siniestro (pasarle el sidepag)
         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;
      END IF;

      IF NVL(x.imp_presta_pensiones_capital, 0) <> 0 THEN   --Traspaso salida
         --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
         cerror := f_crea_siniestro(x, n_seg, 1, 2, NVL(x.imp_presta_pensiones_capital, 0),
                                    vsidepag);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;

         vtraza := 1100;
         --Pagamos el siniestro (pasarle el sidepag)
         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

         IF cerror <> 0 THEN
            RAISE errdatos;
         END IF;
      END IF;

      --Bug.: 18780 - ICV - 15/06/2011
      IF x.empresa = 11
         AND(NVL(x.num_siniestros, 0) <> 0
             OR NVL(x.importe_pagos, 0) <> 0
             OR NVL(x.num_siniestros_cerrados, 0) <> 0) THEN
         --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
         cerror := f_crea_siniestro_generales(x, n_seg, 1, 14, NVL(x.importe_pagos, 0));

         IF cerror <> 0 THEN
            RETURN 2;   --ok
         ELSE
            RETURN 4;
         END IF;

         vtraza := 1150;
      --diversos.. no tienen ctaseguro
      --Pagamos el siniestro (pasarle el sidepag)
      /*cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

      IF cerror <> 0 THEN
         RAISE errdatos;
      END IF;    */
      END IF;

      --Fi Bug 18780

      --      IF NVL(x.imp_presta_vida_siniestros, 0) <> 0 THEN   --Siniestro Parece que no es así
--         --Si no se crea sinisetros pasar directamente a f_crea_ctaseguro
--         cerror := f_crea_siniestro(x, n_seg, 1, 0, NVL(x.imp_presta_vida_siniestros, 0),
--                                    vsidepag);

      --         IF cerror <> 0 THEN
--            RAISE errdatos;
--         END IF;

      --         vtraza := 1100;
--         --Pagamos el siniestro (pasarle el sidepag)
--         cerror := f_crea_ctaseguro(x, n_seg, 3, NULL, vsidepag, NULL, NULL, NULL, FALSE);

      --         IF cerror <> 0 THEN
--            RAISE errdatos;
--         END IF;
--      END IF;
      vtraza := 1100;
      RETURN 4;   --ok
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_alta_siniestros;

/*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************

--JRH FIN PARTE DE AHORRO

AHORRO
CTASEGURO
RENTAS
SINIESTROS/TRASPASOS/PRESTACIONES/RESCATES
SALDO

*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************
*******************************************************************************************/

   -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
   /*************************************************************************
    Funcion que recupera la persona en Host
        param in x: registro tratado tipo int_rga
        param in p_tomador: indica si hay q recuperar el tomador o el propietario: tomador(0), propietario(1)
        param out reg_datos_pers: registro datos persona Host
        param out reg_datos_dir: registro datos direccion Host
        param out reg_datos_contac: registro datos contacto Host
        param out reg_datos_cc: registro datos cuenta Host
        return : 0 si ha ido bien
    *************************************************************************/
   FUNCTION f_busca_person_host(
      x IN int_rga%ROWTYPE,
      p_tomador IN NUMBER,
      reg_datos_pers OUT int_datos_persona%ROWTYPE,
      reg_datos_dir OUT int_datos_direccion%ROWTYPE,
      reg_datos_contac OUT int_datos_contacto%ROWTYPE,
      reg_datos_cc OUT int_datos_cuenta%ROWTYPE,
      psinterf IN OUT int_mensajes.sinterf%TYPE,
      pterror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.F_BUSCA_PERSON_HOST';
      vtraza         NUMBER := 0;
      num_err        NUMBER;
      vcterminal     usuarios.cterminal%TYPE;
      werror         VARCHAR2(2000);
      womasdatos     NUMBER;
      pmasdatos      NUMBER;
      wcont_pers     NUMBER;
      wsperson       per_personas.sperson%TYPE;
      wnnunnif       int_rga.nif_tomador%TYPE;
      err_busca_pers_host EXCEPTION;
   BEGIN
      num_err := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vcterminal);

      IF p_tomador = 0 THEN   -- recuperar persona tomador en host
         wnnunnif := x.nif_tomador;
      ELSE   -- recuperar persona asegurado en host
         wnnunnif := x.nif;
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
         pac_cargas_rga.p_genera_logs(vobj, vtraza, 'Error al buscar persona en host',
                                      'Error: ' || werror || ';sinterf = ' || psinterf
                                      || '; nif = ' || wnnunnif || ' (' || x.proceso || '-'
                                      || x.nlinea || ')',
                                      x.proceso,
                                      'Error al buscar persona en host: ' || werror
                                      || '; nif = ' || wnnunnif || ' (' || x.proceso || '-'
                                      || x.nlinea || ')');
         RETURN num_err;
      ELSE
         -- COMMIT;

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
         pac_cargas_rga.p_genera_logs(vobj, vtraza, 'No encuentra persona en host',
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
         pac_cargas_rga.p_genera_logs(vobj, vtraza,
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
          param in x : registro tipo INT_RGA
      *************************************************************************/
   FUNCTION f_alta_poliza(
      x IN OUT int_rga%ROWTYPE,
      pterror IN OUT VARCHAR2,
      psinterf OUT int_mensajes.sinterf%TYPE)
      -- Bug 0016324. FAL. 26/10/2010. Añadimos desc. error OUT para asignarle sqlerrm cuando sale por when others (normalmente registra errores sobre las tablas mig)
   RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.F_ALTA_POLIZA';
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      errdatos       EXCEPTION;
      v_mig_personas mig_personas%ROWTYPE;
      v_mig_personas_a mig_personas%ROWTYPE;
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_movseg   mig_movseguro%ROWTYPE;
      v_mig_ase      mig_asegurados%ROWTYPE;
      v_mig_rie      mig_riesgos%ROWTYPE;
      v_mig_gar      mig_garanseg%ROWTYPE;
      v_mig_benef    mig_clausuesp%ROWTYPE;
      v_mig_rec      mig_recibos%ROWTYPE;
      v_mig_recdet   mig_detrecibos%ROWTYPE;
      vcdomici       NUMBER;
      verror         VARCHAR2(1000);
      cerror         VARCHAR2(1000);
      terror         VARCHAR2(4000);
      vtraza         NUMBER;
      linea          NUMBER := 0;
      v_warning      BOOLEAN := FALSE;
      vnum_err       NUMBER;
      v_rowid        ROWID;
      v_rowid_ini    ROWID;
      pid            VARCHAR2(200);
      b_warning      BOOLEAN;
      v_tapelli1     VARCHAR2(400);
      v_tapelli2     VARCHAR2(400);
      v_poblac       VARCHAR2(200);
      v_cramo        seguros.cramo%TYPE;
      v_prima        NUMBER;
      v_comi         NUMBER;
      p_deserror     VARCHAR2(200);
      n_aux          NUMBER;
      v_cduraci      productos.cduraci%TYPE;
      --JRH Ahorro
      vcagrpro       NUMBER;
      v_mig_seg_ulk  mig_seguros_ulk%ROWTYPE;
      v_mig_seg_renaho mig_seguros_ren_aho%ROWTYPE;
      -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
      num_err        NUMBER;
      reg_dat_pers   int_datos_persona%ROWTYPE;
      reg_dat_dir    int_datos_direccion%ROWTYPE;
      reg_dat_contac int_datos_contacto%ROWTYPE;
      reg_dat_cc     int_datos_cuenta%ROWTYPE;
   -- Fi Bug 17569
   BEGIN
      vtraza := 1000;
      v_ncarga := f_next_carga;
      x.ncarga := v_ncarga;
      -- Bug 0016324. FAL. 26/10/2010. Asignamos v_ncarga antes de posible error para registrarlo en la linea de carga
      cerror := 0;
      pid := x.nlinea;
      b_warning := FALSE;
      vtraza := 1005;

      SELECT ROWID
        INTO v_rowid_ini
        FROM int_rga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      --Inicializamos la cabecera de la carga
      vtraza := 1010;
      v_ncarga := f_next_carga;
      vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Pólizas', v_seq);
      vtraza := 1015;

      INSERT INTO mig_cargas
                  (ncarga, cempres, finiorg, ffinorg, ID, estorg)
           VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, pid, 'OK');

      vtraza := 1020;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_PERSONAS', 0);

      vtraza := 1025;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_SEGUROS', 1);

      vtraza := 1030;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_MOVSEGURO', 2);

      vtraza := 1035;

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_AGENSEGU', 4);

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

      IF k_busca_host = 1 THEN   -- FAL. 28/06/2011. Parametrizar la busqueda de personas host
         num_err := f_busca_person_host(x, 0, reg_dat_pers, reg_dat_dir, reg_dat_contac,
                                        reg_dat_cc, psinterf, pterror);

         IF num_err <> 0
            AND pterror IS NOT NULL THEN
            SELECT sseqlogmig2.NEXTVAL
              INTO v_seq
              FROM DUAL;

            INSERT INTO mig_logs_axis
                        (ncarga, seqlog, fecha,
                         mig_pk, tipo,
                         incid)
                 VALUES (v_ncarga, v_seq, f_sysdate,
                         v_ncarga || '-' || x.poliza_participe || '-' || x.producto, 'W',
                         'psinterf: ' || psinterf || 'Busqueda persona en Host: ' || pterror);
         END IF;
      END IF;

      -- Fi Bug 0017569
      vtraza := 1045;
      --PERSONAS
      v_mig_personas.mig_pk := v_ncarga || '/' || x.nif_tomador;
      v_mig_personas.idperson := 0;
      v_mig_personas.snip := x.nif_tomador;
      vtraza := 1050;
      v_mig_personas.ctipide := 27;   --nif carga fichero (detvalor 672);
      v_mig_personas.ctipide := NVL(reg_dat_pers.ctipdoc, v_mig_personas.ctipide);
      -- Bug 0017569
      v_mig_personas.cestper := 0;   -- operativa
      v_mig_personas.nnumide := x.nif_tomador;
      v_mig_personas.cpertip := NVL(reg_dat_pers.ctipper, 1);
      v_mig_personas.swpubli := 0;
      v_mig_personas.csexper := NULL;
      v_mig_personas.fnacimi := NVL(reg_dat_pers.fnacimi, x.fec_nac_tomador);   -- Bug 0017569

      -- Bug 0016525. 03/11/2010. FAL. Asignar agente según especificaciones
      -- v_mig_personas.cagente := x.caja_gestora;
      IF x.caja_gestora IS NULL THEN
         v_mig_seg.cagente := SUBSTR(x.cuenta_corriente, 5, 4);
         v_mig_personas.cagente := ff_agente_cpervisio(SUBSTR(x.cuenta_corriente, 5, 4));

         IF v_mig_seg.cagente IN(106, 900, 9008, 9208, 9981, 9221, 9205) THEN
            v_mig_seg.cagente := 9999;
            v_mig_personas.cagente := 9999;
         END IF;
      ELSIF x.caja_gestora = '3081' THEN
         IF x.oficina_gestora = 'AGE8' THEN
            v_mig_seg.cagente := k_agente;
            v_mig_personas.cagente := NVL(ff_agente_cpervisio(k_agente), k_agente);
            cerror := 700145;
            p_deserror := 'x.oficina_gestora = AGE8';
            n_aux :=
               p_marcalinea
                  (x.proceso, x.nlinea, x.tipo_oper, 2, 0, NULL,
                   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.poliza_participe,   -- Fi Bug 14888
                                         -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.ncarga   -- Fi Bug 16324
                           );
            n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
         ELSE
            v_mig_seg.cagente := x.oficina_gestora;
            v_mig_personas.cagente := ff_agente_cpervisio(x.oficina_gestora);

            IF v_mig_seg.cagente IN(106, 900, 9008, 9208, 9981, 9221, 9205) THEN
               v_mig_seg.cagente := 9999;
               v_mig_personas.cagente := 9999;
            END IF;
         END IF;
      ELSE
         v_mig_seg.cagente := x.caja_gestora;
         v_mig_personas.cagente := ff_agente_cpervisio(x.caja_gestora);
      END IF;

      v_mig_personas.cagente := ff_agente_cpervisio(NVL(reg_dat_pers.cagente,
                                                        v_mig_personas.cagente));
      -- Bug 0017569
      -- Fi Bug 0016525
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

      IF x.apellidos_tomador IS NOT NULL THEN
         IF INSTR(x.apellidos_tomador, ' ') = 0 THEN
            v_tapelli1 := x.apellidos_tomador;
            v_tapelli2 := NULL;
         ELSE
            v_tapelli1 := SUBSTR(x.apellidos_tomador, 1, INSTR(x.apellidos_tomador, ' ') - 1);
            v_tapelli2 := SUBSTR(x.apellidos_tomador, INSTR(x.apellidos_tomador, ' ') + 1,
                                 LENGTH(x.apellidos_tomador));
         END IF;
      END IF;

      vtraza := 1075;
      v_mig_personas.tapelli1 := NVL(v_tapelli1, x.nombre_tomador);

      IF x.apellidos_tomador IS NULL THEN
         v_mig_personas.tnombre := NULL;
      ELSE
         v_mig_personas.tnombre := x.nombre_tomador;
      END IF;

      v_mig_personas.tapelli2 := v_tapelli2;
      -- Direccion Particular
      v_mig_personas.ctipdir := 1;
      -- Bug 0016324. FAL. 18/10/2010
      --v_mig_personas.tnomvia := x.direccion_tomador;
      v_mig_personas.tnomvia := SUBSTR(x.direccion_tomador, 1, 40);
      -- Fi Bug 0016324
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

      IF x.cp_tomador IS NULL THEN
         b_warning := TRUE;
         p_genera_logs(vobj, vtraza, 'Código postal',
                       'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                       x.proceso,
                       'Código postal Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                       || ')');
         v_mig_personas.cpostal := NULL;
      ELSE
         v_mig_personas.cpostal := LPAD(x.cp_tomador, 5, '0');
      END IF;

      v_mig_personas.cpostal := NVL(reg_dat_dir.cpostal, v_mig_personas.cpostal);
      -- Bug 0017569
      vtraza := 1095;

      BEGIN
         -- Bug 0016525.03/11/2010.FAL
         IF x.poblacion_tomador IS NULL THEN
            b_warning := TRUE;
            p_genera_logs(vobj, vtraza, 'localidad',
                          'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                          x.proceso,
                          'localidad Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                          || ')');
            v_mig_personas.cprovin := NULL;
            v_mig_personas.cpoblac := NULL;
         ELSE
            DECLARE
               v_localidad    VARCHAR2(200);

               CURSOR c1 IS
                  SELECT DISTINCT b.cprovin, b.cpoblac
                             FROM codpostal c, poblaciones b, provincias a
                            WHERE a.cpais = v_mig_personas.cpais
                              --cprovin = v_mig_personas.cprovin
                              AND b.cprovin = a.cprovin
                              AND(UPPER(b.tpoblac) LIKE UPPER(v_localidad))
                              AND c.cpostal = LPAD(x.cp_tomador, 5, '0')
                              AND c.cprovin = a.cprovin
                              AND c.cpoblac = b.cpoblac
                         ORDER BY 1, 2;
            BEGIN
               vtraza := 1100;
               v_localidad := RTRIM(RTRIM(LTRIM(TRANSLATE(UPPER(x.poblacion_tomador), 'ÁÉÍÓÚ',
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
                               WHERE cpostal = LPAD(x.cp_tomador, 5, '0');

                     vnum_err := pac_int_online.f_crear_poblacion(v_localidad,
                                                                  v_mig_personas.cprovin,
                                                                  LPAD(x.cp_tomador, 5, '0'),
                                                                  v_mig_personas.cpoblac);

                     IF vnum_err <> 0 THEN
                        b_warning := TRUE;
                        p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                      'no definido ' || ' (' || x.proceso || '-' || x.nlinea
                                      || '-' || x.poblacion_tomador || '-' || x.cp_tomador
                                      || ')',
                                      x.proceso,
                                      'localidad cod_postal no definido ' || ' (' || x.proceso
                                      || '-' || x.nlinea || '-' || x.poblacion_tomador || '-'
                                      || x.cp_tomador || ')');
                        v_mig_personas.cprovin := NULL;
                        v_mig_personas.cpoblac := NULL;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        BEGIN
                           SELECT SUBSTR(LPAD(x.cp_tomador, 5, '0'), 1, 2)
                             INTO v_mig_personas.cprovin
                             FROM DUAL;

                           vnum_err :=
                              pac_int_online.f_crear_poblacion(v_localidad,
                                                               v_mig_personas.cprovin,
                                                               LPAD(x.cp_tomador, 5, '0'),
                                                               v_mig_personas.cpoblac);

                           IF vnum_err <> 0 THEN
                              b_warning := TRUE;
                              p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                            'no definido ' || ' (' || x.proceso || '-'
                                            || x.nlinea || '-' || x.poblacion_tomador || '-'
                                            || x.cp_tomador || ')',
                                            x.proceso,
                                            'localidad cod_postal no definido ' || ' ('
                                            || x.proceso || '-' || x.nlinea || '-'
                                            || x.poblacion_tomador || '-' || x.cp_tomador
                                            || ')');
                              v_mig_personas.cprovin := NULL;
                              v_mig_personas.cpoblac := NULL;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS THEN
                              b_warning := TRUE;
                              p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                            'no definido ' || ' (' || x.proceso || '-'
                                            || x.nlinea || '-' || x.poblacion_tomador || '-'
                                            || x.cp_tomador || ')',
                                            x.proceso,
                                            'localidad cod_postal no definido ' || ' ('
                                            || x.proceso || '-' || x.nlinea || '-'
                                            || x.poblacion_tomador || '-' || x.cp_tomador
                                            || ')');
                              v_mig_personas.cprovin := NULL;
                              v_mig_personas.cpoblac := NULL;
                        END;
                  END;
               ELSE
                  CLOSE c1;
               END IF;
            END;
         END IF;
      -- Fi Bug 0016525
      END;

      v_mig_personas.cprovin := NVL(reg_dat_dir.cprovin, v_mig_personas.cprovin);
      -- Bug 0017569
      v_mig_personas.cpoblac := NVL(reg_dat_dir.cpoblac, v_mig_personas.cpoblac);
      -- Bug 0017569
      vtraza := 1110;
      --v_mig_personas.cidioma := k_idiomaaaxis;
      v_mig_personas.cidioma := NVL(reg_dat_pers.cidioma, k_idiomaaaxis);   -- Bug 0017569
      vtraza := 1115;
      v_mig_personas.tnumtel := NULL;

      IF reg_dat_contac.ctipcon = 1 THEN
         v_mig_personas.tnumtel := NVL(reg_dat_contac.tvalcon, v_mig_personas.tnumtel);
      -- Bug 0017569
      END IF;

      vtraza := 1120;

      INSERT INTO mig_personas
           VALUES v_mig_personas
        RETURNING ROWID
             INTO v_rowid;

      vtraza := 1125;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 0, v_mig_personas.mig_pk);

      --PERSONA ASEGURADO
      IF x.nombre <> x.nombre_tomador THEN
         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_PERSONAS', 5);

         vtraza := 10400;
         v_mig_personas_a.ncarga := v_ncarga;
         v_mig_personas_a.cestmig := 1;

         IF x.nif IS NULL THEN
            verror := 'Error en identificador';
            cerror := 110888;
            RAISE errdatos;
         END IF;

         -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
         -- Buscar persona asegurado en Host
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
                        (ncarga, seqlog, fecha,
                         mig_pk, tipo,
                         incid)
                 VALUES (v_ncarga, v_seq, f_sysdate,
                         v_ncarga || '-' || x.poliza_participe || '-' || x.producto, 'W',
                         'psinterf: ' || psinterf || 'Busqueda persona en Host: ' || pterror);
         END IF;

         -- Fi Bug 0017569
         vtraza := 10450;
         --PERSONAS
         v_mig_personas_a.mig_pk := v_ncarga || '/ a /' || x.nif;
         v_mig_personas_a.idperson := 0;
         v_mig_personas_a.snip := x.nif;
         vtraza := 10500;
         v_mig_personas_a.ctipide := 27;   --nif carga fichero (detvalor 672);
         v_mig_personas_a.ctipide := NVL(reg_dat_pers.ctipdoc, v_mig_personas_a.ctipide);
         -- Bug 0017569
         v_mig_personas_a.cestper := 0;   -- operartiva
         v_mig_personas_a.nnumide := x.nif;
         v_mig_personas_a.cpertip := 1;
         v_mig_personas_a.cpertip := NVL(reg_dat_pers.ctipper, 1);
         v_mig_personas_a.swpubli := 0;
         v_mig_personas_a.csexper := NULL;
         v_mig_personas_a.csexper := NVL(reg_dat_pers.csexo, v_mig_personas_a.csexper);
         -- Bug 0017569
         v_mig_personas_a.fnacimi := NVL(reg_dat_pers.fnacimi, x.fec_nac);   -- Bug 0017569

         -- Bug 0016525. 03/11/2010. FAL. Asignar agente según especificaciones
         -- v_mig_personas_a.cagente := x.caja_gestora;
         IF x.caja_gestora IS NULL THEN
            v_mig_personas_a.cagente := ff_agente_cpervisio(SUBSTR(x.cuenta_corriente, 5, 4));
         ELSIF x.caja_gestora = '3081' THEN
            IF x.oficina_gestora = 'AGE8' THEN
               v_mig_personas_a.cagente := NVL(ff_agente_cpervisio(k_agente), k_agente);
               cerror := 700145;
               p_deserror := 'x.oficina_gestora = AGE8';
               n_aux :=
                  p_marcalinea
                     (x.proceso, x.nlinea, x.tipo_oper, 2, 0, NULL,
                      -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      x.poliza_participe,   -- Fi Bug 14888
                                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      x.ncarga   -- Fi Bug 16324
                              );
               n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
            ELSE
               v_mig_personas_a.cagente := ff_agente_cpervisio(x.oficina_gestora);
            END IF;
         ELSE
            v_mig_personas_a.cagente := ff_agente_cpervisio(x.caja_gestora);
         END IF;

         v_mig_personas_a.cagente := NVL(reg_dat_pers.cagente, v_mig_personas_a.cagente);
         -- Bug 0017569
            -- Fi Bug 0016525
         vtraza := 10700;

         IF x.nombre IS NULL THEN
            b_warning := TRUE;
            p_genera_logs(vobj, vtraza, 'Nombre Asegurado',
                          'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                          x.proceso,
                          'Nombre Asegurado' || ' (' || x.proceso || '-' || x.nlinea || ')');
            x.nombre := ' ';
         END IF;

         IF x.apellidos IS NOT NULL THEN
            IF INSTR(x.apellidos, ' ') = 0 THEN
               v_tapelli1 := x.apellidos;
               v_tapelli2 := NULL;
            ELSE
               v_tapelli1 := SUBSTR(x.apellidos, 1, INSTR(x.apellidos, ' ') - 1);
               v_tapelli2 := SUBSTR(x.apellidos, INSTR(x.apellidos, ' ') + 1,
                                    LENGTH(x.apellidos));
            END IF;
         END IF;

         vtraza := 10750;
         v_mig_personas_a.tapelli1 := NVL(v_tapelli1, x.nombre);
         v_mig_personas_a.tapelli2 := v_tapelli2;

         IF x.apellidos IS NULL THEN
            v_mig_personas_a.tnombre := NULL;
         ELSE
            v_mig_personas_a.tnombre := x.nombre;
         END IF;

         --v_mig_personas_a.tnombre := x.nombre;
         -- Direccion Particular
         v_mig_personas_a.ctipdir := 1;
         v_mig_personas_a.tnomvia := SUBSTR(x.direccion, 1, 40);
         v_mig_personas_a.nnumvia := NULL;
         v_mig_personas_a.tcomple := NULL;
         v_mig_personas_a.cpais := k_paisdefaxis;
         v_mig_personas_a.cnacio := k_paisdefaxis;
         -- Bug 0017569 - FAL - 02/03/2011 - CRT - Interfases y gestión personas
         v_mig_personas_a.tapelli1 := NVL(reg_dat_pers.tapelli1, v_mig_personas_a.tapelli1);
         v_mig_personas_a.tapelli2 := NVL(reg_dat_pers.tapelli2, v_mig_personas_a.tapelli2);
         v_mig_personas_a.tnombre := NVL(reg_dat_pers.tnombre, v_mig_personas_a.tnombre);
         -- Direccion Particular
         v_mig_personas_a.ctipdir := NVL(reg_dat_dir.ctipdir, v_mig_personas_a.ctipdir);
         v_mig_personas_a.tnomvia := NVL(reg_dat_dir.tnomvia, v_mig_personas_a.tnomvia);
         v_mig_personas_a.nnumvia := NVL(reg_dat_dir.nnumvia, v_mig_personas_a.nnumvia);
         v_mig_personas_a.tcomple := NULL;
         v_mig_personas_a.cpais := NVL(reg_dat_pers.cpais, v_mig_personas_a.cpais);
         v_mig_personas_a.cnacio := NVL(reg_dat_pers.cnacioni, v_mig_personas_a.cnacio);
         -- Fi Bug 17569
         vtraza := 10850;

         IF x.cp IS NULL THEN
            b_warning := TRUE;
            p_genera_logs(vobj, vtraza, 'Código postal',
                          'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                          x.proceso,
                          'Código postal Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                          || ')');
            v_mig_personas_a.cpostal := NULL;
         ELSE
            v_mig_personas_a.cpostal := LPAD(x.cp, 5, '0');
         END IF;

         v_mig_personas_a.cpostal := NVL(reg_dat_dir.cpostal, v_mig_personas_a.cpostal);
         -- Bug 0017569
         vtraza := 10950;

         BEGIN
            IF x.poblacion IS NULL THEN
               b_warning := TRUE;
               p_genera_logs(vobj, vtraza, 'localidad',
                             'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                             x.proceso,
                             'localidad Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                             || ')');
               v_mig_personas_a.cprovin := NULL;
               v_mig_personas_a.cpoblac := NULL;
            ELSE
               DECLARE
                  v_localidad    VARCHAR2(200);

                  CURSOR c1 IS
                     SELECT DISTINCT b.cprovin, b.cpoblac
                                FROM codpostal c, poblaciones b, provincias a
                               WHERE a.cpais = v_mig_personas_a.cpais
                                 --cprovin = v_mig_personas.cprovin
                                 AND b.cprovin = a.cprovin
                                 AND(UPPER(b.tpoblac) LIKE UPPER(v_localidad))
                                 AND c.cpostal = LPAD(x.cp, 5, '0')
                                 AND c.cprovin = a.cprovin
                                 AND c.cpoblac = b.cpoblac
                            ORDER BY 1, 2;
               BEGIN
                  vtraza := 1100;
                  v_localidad := RTRIM(RTRIM(LTRIM(TRANSLATE(UPPER(x.poblacion), 'ÁÉÍÓÚ',
                                                             'AEIOU'))),
                                       '.');
                  vtraza := 1105;

                  OPEN c1;

                  FETCH c1
                   INTO v_mig_personas_a.cprovin, v_mig_personas_a.cpoblac;

                  IF c1%NOTFOUND THEN
                     CLOSE c1;

                     BEGIN
                        SELECT DISTINCT cprovin
                                   INTO v_mig_personas_a.cprovin
                                   FROM codpostal
                                  WHERE cpostal = LPAD(x.cp, 5, '0');

                        vnum_err := pac_int_online.f_crear_poblacion(v_localidad,
                                                                     v_mig_personas_a.cprovin,
                                                                     LPAD(x.cp, 5, '0'),
                                                                     v_mig_personas_a.cpoblac);

                        IF vnum_err <> 0 THEN
                           b_warning := TRUE;
                           p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                         'no definido ' || ' (' || x.proceso || '-'
                                         || x.nlinea || '-' || x.poblacion || '-' || x.cp
                                         || ')',
                                         x.proceso,
                                         'localidad cod_postal no definido ' || ' ('
                                         || x.proceso || '-' || x.nlinea || '-' || x.poblacion
                                         || '-' || x.cp || ')');
                           v_mig_personas_a.cprovin := NULL;
                           v_mig_personas_a.cpoblac := NULL;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           BEGIN
                              SELECT SUBSTR(LPAD(x.cp, 5, '0'), 1, 2)
                                INTO v_mig_personas_a.cprovin
                                FROM DUAL;

                              vnum_err :=
                                 pac_int_online.f_crear_poblacion(v_localidad,
                                                                  v_mig_personas_a.cprovin,
                                                                  LPAD(x.cp, 5, '0'),
                                                                  v_mig_personas_a.cpoblac);

                              IF vnum_err <> 0 THEN
                                 b_warning := TRUE;
                                 p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                               'no definido ' || ' (' || x.proceso || '-'
                                               || x.nlinea || '-' || x.poblacion || '-'
                                               || x.cp || ')',
                                               x.proceso,
                                               'localidad cod_postal no definido ' || ' ('
                                               || x.proceso || '-' || x.nlinea || '-'
                                               || x.poblacion || '-' || x.cp || ')');
                                 v_mig_personas_a.cprovin := NULL;
                                 v_mig_personas_a.cpoblac := NULL;
                              END IF;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 b_warning := TRUE;
                                 p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                               'no definido ' || ' (' || x.proceso || '-'
                                               || x.nlinea || '-' || x.poblacion || '-'
                                               || x.cp || ')',
                                               x.proceso,
                                               'localidad cod_postal no definido ' || ' ('
                                               || x.proceso || '-' || x.nlinea || '-'
                                               || x.poblacion || '-' || x.cp || ')');
                                 v_mig_personas_a.cprovin := NULL;
                                 v_mig_personas_a.cpoblac := NULL;
                           END;
                     END;
                  ELSE
                     CLOSE c1;
                  END IF;
               END;
            END IF;
         -- Fi Bug 0016525
         END;

         v_mig_personas_a.cprovin := NVL(reg_dat_dir.cprovin, v_mig_personas_a.cprovin);
         -- Bug 0017569
         v_mig_personas_a.cpoblac := NVL(reg_dat_dir.cpoblac, v_mig_personas_a.cpoblac);
         -- Bug 0017569
         vtraza := 11100;
         v_mig_personas_a.cidioma := k_idiomaaaxis;
         v_mig_personas_a.cidioma := NVL(reg_dat_pers.cidioma, v_mig_personas_a.cidioma);
         -- Bug 0017569
         vtraza := 11150;
         v_mig_personas_a.tnumtel := NULL;

         IF reg_dat_contac.ctipcon = 1 THEN
            v_mig_personas_a.tnumtel := NVL(reg_dat_contac.tvalcon, v_mig_personas_a.tnumtel);
         -- Bug 0017569
         END IF;

         vtraza := 11200;

         INSERT INTO mig_personas
              VALUES v_mig_personas_a
           RETURNING ROWID
                INTO v_rowid;

         vtraza := 11250;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 5, v_mig_personas_a.mig_pk);
      END IF;

      --SEGUROS
      v_mig_seg.mig_pk := v_ncarga || '-' || x.poliza_participe || '-' || x.producto;
      v_mig_seg.mig_fk := v_mig_personas.mig_pk;
      --v_mig_seg.cagente       := v_mig_personas.cagente;
      v_mig_seg.csituac := 0;
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
      vtraza := 1130;
      v_mig_seg.fefecto := NVL(TO_DATE(x.fec_efecto, 'dd/mm/rrrr'),
                               TO_DATE(x.fec_contratacion, 'dd/mm/rrrr'));

      IF v_mig_seg.fefecto IS NULL THEN
         verror := 'Fecha de efecto nula ';
         cerror := 1000135;
         RAISE errdatos;
      END IF;

      vtraza := 1140;
      --Buscamos el producto
      v_mig_seg.sproduc := pac_cargas_rga.f_buscavalor('CRT_PRODRGA', x.producto);
      vtraza := 1145;

      IF v_mig_seg.sproduc IS NULL THEN
         p_deserror := 'Producto desconocido';
         cerror := 104347;
         RAISE errdatos;
      END IF;

      vtraza := 1146;

      /*SELECT b.cramo   -- min(b.cramo)
            INTO v_cramo
      FROM productos b
      WHERE b.sproduc = v_mig_seg.sproduc;
      */
      SELECT cramo, ccompani, cduraci, cpagdef, cagrpro
        INTO v_cramo, v_mig_seg.ccompani, v_cduraci, v_mig_seg.cforpag, vcagrpro
        FROM productos
       WHERE sproduc = v_mig_seg.sproduc;

      vtraza := 1148;

      --Para agroseguro el cforpag es nulo, cogemos el de por defecto del producto
      IF x.forma_pago IS NULL
         OR x.forma_pago = 'E' THEN
         -- JLB 'E' igual a nulo es un error que llega en un fichero de
         NULL;   -- cogemos la forma de pago por defecto del producto
      ELSE
         IF x.forma_pago = 'U' THEN
            v_mig_seg.cforpag := 0;
         ELSE
            v_mig_seg.cforpag := x.forma_pago;
         END IF;
      END IF;

      vtraza := 1150;
      v_mig_seg.npoliza := f_contador('02', v_cramo);
      v_mig_seg.ncertif := 0;
      vtraza := 1160;
      v_mig_seg.creafac := 0;   --Revisar
      -- Vamos por actividad

      --jlb
      v_mig_seg.cactivi := pac_cargas_rga.f_buscavalor('CRT_ACTIVRGA', x.producto);

      IF v_mig_seg.cactivi IS NULL THEN
         BEGIN
            SELECT cactivi
              INTO v_mig_seg.cactivi
              FROM activiprod a, productos p
             WHERE p.sproduc = v_mig_seg.sproduc
               AND p.cramo = a.cramo
               AND p.cmodali = a.cmodali
               AND p.ctipseg = a.ctipseg
               AND p.ccolect = a.ccolect;
         EXCEPTION
            WHEN OTHERS THEN
               verror := ' producto ' || x.producto || ' - axis: - ' || v_mig_seg.sproduc;
               cerror := 9000731;
               RAISE errdatos;
         END;
      END IF;

      vtraza := 1165;
      v_mig_seg.ctipcoa := 0;
      v_mig_seg.ctiprea := 0;
      v_mig_seg.ctipcom := 0;   --Habitual
      vtraza := 1170;

      IF x.fec_vencimiento IS NOT NULL THEN
         v_mig_seg.fvencim := TO_DATE(x.fec_vencimiento, 'dd/mm/rrrr');
      END IF;

      /*IF v_mig_seg.fvencim IS NULL THEN
                                                                               verror := 'Vencimiento no valido: ' || x.fec_vencimiento;
         cerror := 1000135;
         RAISE errdatos;
      END IF;*/
      vtraza := 1180;
      v_mig_seg.femisio := v_mig_seg.fefecto;
      v_mig_seg.iprianu := x.prima_neta_anualizada;
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
      --   v_mig_seg.ccompani      := NULL;  -- deberia ser RGA
      vtraza := 1190;
      v_mig_seg.crevali := 0;
      v_mig_seg.prevali := 0;
      v_mig_seg.irevali := 0;
      vtraza := 1195;

      IF NVL(TRIM(x.cuenta_corriente), '0') = '0'
         OR LENGTH(x.cuenta_corriente) < 20 THEN
         v_mig_seg.ctipban := NULL;
         v_mig_seg.cbancar := NULL;
         v_mig_seg.ctipcob := 1;
      ELSE
         vtraza := 1200;
         v_mig_seg.ctipban := 1;
         v_mig_seg.cbancar := x.cuenta_corriente;
         v_mig_seg.ctipcob := 2;
      END IF;

      vtraza := 1210;
      --    v_mig_seg.ctipcob       := 1;  -- ya se calcula arriba
      v_mig_seg.casegur := 1;
      v_mig_seg.nsuplem := 0;
      v_mig_seg.sseguro := 0;
      v_mig_seg.sperson := 0;
      vtraza := 1200;
      vcdomici := 1;
      v_mig_seg.crecfra := 0;
      vtraza := 1210;
      --v_mig_seg.npolini := x.poliza_participe; -- no guardo la poliza
      v_mig_seg.mig_fk := v_mig_personas.mig_pk;
      vtraza := 1215;
      vtraza := 1220;
      v_mig_seg.ccobban := NULL;
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

      --actualizo la primera nota informativa
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
      -- v_mig_movseg.fmovimi := v_mig_seg.femisio;   --f_sysdate;
      v_mig_movseg.mig_pk := v_mig_seg.mig_pk;
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
           VALUES (v_ncarga, 'INT_RGA', 'MIG_ASEGURADOS', 6);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_RIESGOS', 7);

      vtraza := 1245;
      v_mig_ase.sseguro := 0;
      v_mig_ase.sperson := 0;
      v_mig_ase.norden := 1;
      vtraza := 1250;
      v_mig_ase.ffecini := v_mig_seg.fefecto;
      v_mig_ase.ffecfin := NULL;
      v_mig_ase.ffecmue := NULL;
      v_mig_ase.mig_pk := v_mig_seg.mig_pk;
      v_mig_ase.mig_fk := NVL(v_mig_personas_a.mig_pk, v_mig_personas.mig_pk);
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
           VALUES (0, v_ncarga, 6, v_mig_ase.mig_pk);

      vtraza := 1260;
      ---
      v_mig_rie.nriesgo := 1;
      v_mig_rie.sseguro := 0;
      v_mig_rie.nmovima := 1;
      v_mig_rie.fefecto := v_mig_seg.fefecto;
      v_mig_rie.sperson := NULL;
      v_mig_rie.nmovimb := NULL;
      v_mig_rie.fanulac := NULL;
      v_mig_rie.tnatrie := NULL;
      vtraza := 1265;
      v_mig_rie.mig_pk := v_mig_seg.mig_pk;
      --v_mig_rie.mig_fk := v_mig_seg.mig_fk;
      v_mig_rie.mig_fk := v_mig_ase.mig_fk;
      v_mig_rie.mig_fk2 := v_mig_seg.mig_pk;
      v_mig_rie.cestmig := 1;
      v_mig_rie.ncarga := v_ncarga;
      vtraza := 1270;

      INSERT INTO mig_riesgos
           VALUES v_mig_rie
        RETURNING ROWID
             INTO v_rowid;

      INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 7, v_mig_rie.mig_pk);

      INSERT INTO mig_cargas_tab_mig
                  (ncarga, tab_org, tab_des, ntab)
           VALUES (v_ncarga, 'INT_RGA', 'MIG_GARANSEG', 8);

      vtraza := 1275;

      FOR reg IN (SELECT   *
                      FROM garanpro
                     WHERE sproduc = v_mig_seg.sproduc
                       AND cactivi = v_mig_seg.cactivi
                  ORDER BY norden ASC) LOOP
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

         --IF reg.norden = 1 THEN
         IF x.imp_capital_final_vida <> 0 THEN
            IF v_mig_gar.cgarant = 48 THEN
               IF NVL(v_mig_seg.cforpag, 0) <> 0 THEN
                  v_mig_gar.icapital := ROUND(NVL(ABS(x.prima_neta_anualizada), 0)
                                              / v_mig_seg.cforpag,
                                              2);
               ELSE
                  v_mig_gar.icapital := NVL(ABS(x.prima_neta_anualizada), 0);
               END IF;
            ELSIF v_mig_gar.cgarant = 288 THEN
               v_mig_gar.icapital := x.imp_capital_final_vida;
            ELSE
               v_mig_gar.icapital := 0;
            END IF;
         ELSE
            --HOGAR
            IF reg.cgarant NOT IN(7706, 7713, 7709, 7710) THEN   --Solo son de hogar
               v_mig_gar.icapital := x.capital_asegurado;
            ELSIF reg.cgarant = 7709 THEN   --Contenido
               v_mig_gar.icapital := NVL(x.capital_2, 0);
            ELSIF reg.cgarant = 7710 THEN   --Joyas Fuera
               v_mig_gar.icapital := NVL(x.capital_3, 0);
            ELSIF reg.cgarant = 7713 THEN   --Alimentos refrigerados
               v_mig_gar.icapital := NVL(x.capital_4, 0);
            ELSIF reg.cgarant = 7706 THEN   --Objetos de Valor
               v_mig_gar.icapital := NVL(x.capital_5, 0);
            END IF;
         END IF;

         IF reg.cgarant NOT IN(7706, 7713, 7709, 7710, 288) THEN   --Solo son de hogar / vida
            IF v_mig_gar.cgarant NOT IN(48)
               AND x.imp_capital_final_vida <> 0 THEN
               v_mig_gar.iprianu := 0;
               v_mig_gar.ipritar := 0;
            ELSE
               v_mig_gar.iprianu := NVL(ABS(x.prima_neta_anualizada), 0);
               v_mig_gar.ipritar := NVL(ABS(x.prima_neta_anualizada), 0);
            END IF;
         END IF;

         /*ELSE
            v_mig_gar.icapital := 0;
            v_mig_gar.iprianu := 0;
            v_mig_gar.ipritar := 0;
         END IF;*/
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
      END LOOP;

      --Migramos el beneficiario
      vtraza := 1350;

      IF x.beneficiario IS NOT NULL THEN
         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_CLAUSUESP', 9);

         v_mig_benef := NULL;
         v_mig_benef.mig_pk := v_mig_seg.mig_pk || ' / ' || '1';
         v_mig_benef.mig_fk := v_mig_seg.mig_pk;
         v_mig_benef.cestmig := 1;
         v_mig_benef.ncarga := v_ncarga;
         v_mig_benef.nmovimi := v_mig_movseg.nmovimi;
         v_mig_benef.sseguro := 0;
         v_mig_benef.cclaesp := 1;
         v_mig_benef.nordcla := 1;
         v_mig_benef.nriesgo := 1;
         v_mig_benef.finiclau := v_mig_seg.fefecto;
         v_mig_benef.sclagen := NULL;
         v_mig_benef.tclaesp := SUBSTR(x.beneficiario, 1, 2000);
         v_mig_benef.ffinclau := NULL;

         INSERT INTO mig_clausuesp
              VALUES v_mig_benef
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 9, v_mig_benef.mig_pk);
      END IF;

-------------------- FINAL ---------------------
      IF x.empresa IN(12, 13)
         AND v_cramo <> 82   -- diferente de vida riesgo
                          --AND NVL(pac_mdpar_productos.f_get_parproducto('CUENTA_SEGURO', v_mig_seg.sproduc), 0) = 1
      THEN
         --JRH IMP Faltan Seguros_aho,Seguros_ren,Seguros_ulk,Segdisin2
         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_SEGUROS_REN_AHO', 10);

         v_mig_seg_renaho := NULL;
         v_mig_seg_renaho.mig_pk := v_mig_seg.mig_pk;
         v_mig_seg_renaho.ncarga := v_ncarga;
         v_mig_seg_renaho.cestmig := 1;
         v_mig_seg_renaho.mig_fk := v_mig_seg.mig_pk;
         v_mig_seg_renaho.sseguro := 0;   --JRH IMP Ya veremos que campos le ponemos

         INSERT INTO mig_seguros_ren_aho
              VALUES v_mig_seg_renaho
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 10, v_mig_seg_renaho.mig_pk);
      END IF;

----JRH  ULK
      IF vcagrpro IN(2, 11, 21)
         AND v_cramo <> 82
                          --  AND NVL(pac_mdpar_productos.f_get_parproducto('CUENTA_SEGURO', v_mig_seg.sproduc), 0) = 1
      THEN   -- tenmos productos de vida que no teien cuenta seguro
         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_SEGUROS_ULK', 11);

         v_mig_seg_ulk := NULL;
         v_mig_seg_ulk.mig_pk := v_mig_seg.mig_pk;
         v_mig_seg_ulk.ncarga := v_ncarga;
         v_mig_seg_ulk.cestmig := 1;
         v_mig_seg_ulk.mig_fk := v_mig_seg.mig_pk;
         v_mig_seg_ulk.sseguro := 0;
         vtraza := 25;

         -- v_mig_seg_ulk.cmodinv := 1;
         BEGIN
            SELECT cmodinv
              INTO v_mig_seg_ulk.cmodinv
              FROM modinvfondo, productos
             WHERE modinvfondo.cramo = productos.cramo
               AND modinvfondo.cmodali = productos.cmodali
               AND modinvfondo.ctipseg = productos.ctipseg
               AND modinvfondo.ccolect = productos.ccolect
               AND productos.sproduc = v_mig_seg.sproduc;
         EXCEPTION
            WHEN OTHERS THEN
               v_mig_seg_ulk.cmodinv := 1;   --JRH IMP de momento
         END;

         INSERT INTO mig_seguros_ulk
              VALUES v_mig_seg_ulk
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 11, v_mig_seg_ulk.mig_pk);
      END IF;

      vtraza := 1475;

      UPDATE int_rga
         SET ncarga = v_ncarga
       WHERE proceso = x.proceso
         AND nlinea = x.nlinea;

      vtraza := 1405;
      x.ncarga := v_ncarga;

      -- COMMIT;
      IF b_warning THEN
         cerror := -2;
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         pac_cargas_rga.p_genera_logs(vobj, vtraza, 'Error ' || cerror, verror, x.proceso,
                                      'Error ' || cerror || ' ' || verror);
         pterror := verror;
         -- Bug 0016324. FAL. 26/10/2010. Informa desc. error para registrar linea de error y no aparezca un literal en el detalle->mensajes de la pnatalla resultado cargas
         RETURN cerror;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_cargas_rga.p_genera_logs(vobj, vtraza, 'ERROR ' || SQLCODE, SQLERRM, x.proceso,
                                      'Error ' || SQLCODE || ' ' || SQLERRM);
         cerror := SQLCODE;   -- Bug 0016324. FAL. 26/10/2010. Devuelve sqlcode como error
         pterror := SQLERRM;
         -- Bug 0016324. FAL. 26/10/2010. Devuelve sqlerrm como desc. error;
         RETURN cerror;
   END f_alta_poliza;

   /*************************************************************************
                                               procedimiento que genera anulación de póliza
          param in x : registro tipo INT_POLIZAS_RGA
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
   FUNCTION f_baja_poliza(x IN OUT int_rga%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.F_BAJA_POLIZA';
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
      NULL;
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
      vtraza := 1020;

      BEGIN
         n_pro := pac_cargas_rga.f_buscavalor('CRT_PRODRGA', x.producto);

         SELECT sseguro, cagente, sproduc, csituac, npoliza
           INTO n_seg, n_age, n_pro, w_csituac, wnpoliza
           FROM seguros
          WHERE cpolcia = x.poliza_participe
            AND sproduc = n_pro;

         n_aux := 1;
      EXCEPTION
         WHEN OTHERS THEN
            n_aux := 0;
      END;

      vtraza := 1030;

      IF n_aux = 0 THEN
         p_deserror := 'Número póliza no existe: ' || x.poliza_participe;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1040;
      d_baj := TO_DATE(x.fec_anulacion, 'dd/mm/rrrr');
      vtraza := 1050;
      v_des2 := x.motivo_anulacion;
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

      -- Bug 0016324. FAL. 18/10/2010
      IF w_csituac <> 0 THEN   -- No permita anular poliza si ya lo está
         p_deserror := 'La póliza ' || TO_CHAR(wnpoliza) || ' no esta vigente';
         cerror := 101483;
         n_aux := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 2, 1, n_seg,

                               -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                               x.poliza_participe,   -- Fi Bug 14888
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
                   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.poliza_participe,   -- Fi Bug 14888
                                         -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   x.ncarga   -- Fi Bug 16324
                           );

            IF n_aux <> 0 THEN   -- Si fallan estas funciones de gestión salimos del programa
               RAISE errdatos;
            END IF;
         END IF;

         --    UPDATE seguros
           --     SET fcarpro = NULL
            --  WHERE sseguro = n_seg;
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
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.P_INICIAR_SUPLE';
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
            p_des := p_des
                     || '. Editar la linea, modificar fecha suplemento y reprocesar linea';
         END IF;

         RAISE errdatos;
      END IF;

      vtraza := 1061;
      p_est := NULL;
      cerror := pk_suplementos.f_inicializar_suplemento(p_seg, 'SUPLEMENTO', p_efe, 'BBDD',
                                                        '*', p_mot, p_est, p_mov, 'NOPRAGMA');

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
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.P_FINALIZAR_SUPLE';
      vtraza         NUMBER;
      cerror         NUMBER;
      e_nosuple      EXCEPTION;
      errdatos       EXCEPTION;
      n_aux          NUMBER;
      indice         NUMBER;
      indice_e       NUMBER;
      indice_t       NUMBER;
      r_seg          seguros%ROWTYPE;
      v_fefecto      DATE;
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

      /*SELECT fefecto
        INTO v_fefecto
        FROM estseguros
       WHERE sseguro = p_est;*/
      BEGIN
         INSERT INTO pds_estsegurosupl
                     (sseguro, nmovimi, cmotmov, fsuplem, cestado)
              VALUES (p_est, p_mov, p_cmotmov, pfsuplem, 'X');
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;   --si ya existe es que están haciendo más suplementos
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_CARGAS_RGA', 1,
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

   FUNCTION f_emitir_propuesta(p_seg IN NUMBER, p_des OUT VARCHAR2, pproceso IN NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.f_emitir_propuesta';
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
      WHEN errdatos THEN
         RETURN cerror;
   END f_emitir_propuesta;

   /*************************************************************************
                                   procedimiento que genera suplemento con modificacion de póliza
          param in x : registro tipo int_polizas_RGA
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
   FUNCTION f_modi_poliza(x IN OUT int_rga%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.F_MODI_POLIZA';
      vtraza         NUMBER;
      cerror         NUMBER;
      v_haysuplementos NUMBER := 0;
      errdatos       EXCEPTION;
      n_seg          seguros.sseguro%TYPE;
      n_csituac      seguros.csituac%TYPE;
      n_pro          seguros.sproduc%TYPE;
      n_aux          NUMBER;
      d_efe          seguros.fefecto%TYPE;
      d_efepro       DATE;
      vfcarpro       DATE;
      vfcaranu       DATE;
      vfvencim       DATE;
      d_sup          movseguro.fefecto%TYPE;
      n_vig          NUMBER;
      n_est          estseguros.sseguro%TYPE;
      n_mov          movseguro.nmovimi%TYPE;
      d_aux          DATE;
      n_perest       esttomadores.sperson%TYPE;
      n_cagente      seguros.cagente%TYPE;
      b_warning      BOOLEAN;
      v_deswarning   VARCHAR2(1000);
      v_poliza_rga   VARCHAR2(1000);
      v_sproduc      productos.sproduc%TYPE;
      v_prima        NUMBER := 0;
      v_impreal      NUMBER := 0;
      v_capital      NUMBER := 0;
      v_comi         NUMBER := 0;
      --Recibo
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_rec      mig_recibos%ROWTYPE;
      v_mig_recdet   mig_detrecibos%ROWTYPE;
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      vnum_err       NUMBER;
      v_rowid        ROWID;
      v_i            BOOLEAN := FALSE;
      v_iprianu      NUMBER;
      v_cforpag      seguros.cforpag%TYPE;
      v_movcart      NUMBER := 0;
      nmeses         NUMBER := 0;
      --w_cambio_cc    NUMBER;
      wcnordban      NUMBER;
      -- FAL - 31/10/2010 - Bug 19926: CRT002 - Suplemento Cambio de tomador en las cargas (RGA)
      psinterf       int_mensajes.sinterf%TYPE;
      pterror        VARCHAR2(500);
      reg_dat_pers   int_datos_persona%ROWTYPE;
      reg_dat_dir    int_datos_direccion%ROWTYPE;
      reg_dat_contac int_datos_contacto%ROWTYPE;
      reg_dat_cc     int_datos_cuenta%ROWTYPE;
      v_mig_personas mig_personas%ROWTYPE;
      v_haycambio_tomador NUMBER;
      num_err        NUMBER;
      v_tapelli1     VARCHAR2(400);
      v_tapelli2     VARCHAR2(400);
      terror         VARCHAR2(4000);
      verrorgrab     EXCEPTION;
      warning_alta_host BOOLEAN := FALSE;
      v_haycambio_asegurado NUMBER;
      w_norden_assegurat_antic NUMBER;
      w_sperson_assegurat_antic NUMBER;
      wnif_asegurat_antic int_rga.nif%TYPE;
      wnif_tomador_antic int_rga.nif_tomador%TYPE;
      w_sperson_tomador_antic NUMBER;
      wwtraza        NUMBER;
      wspersonnueva  NUMBER;
      wpersfict      NUMBER;
      w_aux          NUMBER;
   -- Fi Bug 19926
   BEGIN
      --Comprobación por prima anualizada
      /*  -- FAL. pasamos a comparar prima_neta_anualizada en select de abajo
      SELECT COUNT('x')
        INTO v_haysuplementos
        FROM (SELECT x.prima_neta_anualizada
                FROM DUAL
              MINUS
              SELECT prima_neta_anualizada
                FROM int_rga
               WHERE poliza_participe = x.poliza_participe
                 AND producto = x.producto
                 AND proceso = (SELECT MAX(proceso)
                                  FROM int_rga
                                 WHERE poliza_participe = x.poliza_participe
                                   AND producto = x.producto
                                   AND proceso < x.proceso));
        */

      -- IF v_haysuplementos = 0 THEN
         -- antes de nada miro si hay algun cambio por realizar
      SELECT COUNT('x')
        INTO v_haysuplementos
        FROM (SELECT TO_DATE(x.fec_vencimiento, 'dd/mm/rrrr'), x.cuenta_corriente,
                     NVL(x.forma_pago, 0), x.imp_capital_final_vida, x.capital_asegurado,
                     NVL(x.capital_2, 0), NVL(x.capital_3, 0), NVL(x.capital_4, 0),
                     NVL(x.capital_5, 0), x.oficina_gestora, NVL(x.prima_neta_anualizada, 0),

                     -- -- FAL. comparar prima_neta_anualizada
                     NVL(x.nif_tomador, '0'), NVL(x.nif, '0')
                FROM DUAL
              MINUS
              SELECT TO_DATE(fec_vencimiento, 'dd/mm/rrrr'), cuenta_corriente,
                     NVL(forma_pago, 0), imp_capital_final_vida, capital_asegurado,
                     NVL(capital_2, 0), NVL(capital_3, 0), NVL(capital_4, 0),
                     NVL(capital_5, 0), oficina_gestora, NVL(prima_neta_anualizada, 0),
                     NVL(nif_tomador, '0'), NVL(nif, '0')
                FROM int_rga
               WHERE poliza_participe = x.poliza_participe
                 AND producto = x.producto
                 AND proceso = (SELECT MAX(proceso)
                                  FROM int_rga
                                 WHERE poliza_participe = x.poliza_participe
                                   AND producto = x.producto
                                   AND proceso < x.proceso));

      -- END IF;

      --AND proceso <> x.proceso)); --> ICV CAMBIO A MENOR POR SI SE TIRA PARA ATRAS Y SE VUELVE A CARGA O ESTA UN FICHERO MAYOR EN INT_RGA PERO AUN NO SE HAN CARGADO
      IF TO_CHAR(TO_DATE(x.fec_efecto, 'dd/mm/rrrr'), 'mm') =
                                     TO_CHAR(TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'), 'mm')
         AND NVL(x.forma_pago, 0) <> 'U' THEN
         --Si estamos en el mes de última renovación es una cartera de renovación
         v_movcart := 1;
         v_haysuplementos := 1;
      END IF;

      IF v_haysuplementos = 0 THEN   --Comprobamos si viene un recibo
         IF NVL(x.importe_emitidos_prod, 0) = 0
            AND NVL(x.importe_anulados_prod, 0) = 0
            AND NVL(x.importe_emitidos_cart, 0) = 0
            AND NVL(x.importe_anulados_cart, 0) = 0
            AND NVL(x.importe_emitidos_recur, 0) = 0
            AND NVL(x.importe_anulados_recur, 0) = 0 THEN
            NULL;
         --v_haysuplementos := 0;
         ELSE
            --FAL. si llega recibo y póliza no vigente aólo  y genera recibo. No genera suplemento.
            v_poliza_rga := x.poliza_participe;
            v_sproduc := pac_cargas_rga.f_buscavalor('CRT_PRODRGA', x.producto);

            BEGIN
               SELECT sseguro, sproduc, fefecto,
                      f_vigente(sseguro, NULL,
                                GREATEST(TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'), fefecto)),
                      fcarpro, cforpag, fvencim, cagente, csituac
                 INTO n_seg, n_pro, d_efe,
                      n_vig,
                      d_efepro, v_cforpag, vfvencim, n_cagente, n_csituac
                 FROM seguros
                WHERE cpolcia = v_poliza_rga
                  AND sproduc = v_sproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT seg.sseguro, sproduc, fefecto, 0,   -- es un alta
                                                             csituac, fcarpro, cforpag,
                            fvencim, seg.cagente
                       INTO n_seg, n_pro, d_efe, n_vig, n_csituac, d_efepro, v_cforpag,
                            vfvencim, n_cagente
                       FROM seguros seg, tomadores tom, per_personas per
                      WHERE fefecto = TO_DATE(x.fec_efecto, 'dd/mm/rrrr')
                        AND sproduc = v_sproduc
                        AND tom.sseguro = seg.sseguro
                        AND per.sperson = tom.sperson
                        AND cpolcia IS NULL
                        -- cualquier tomador con ese nif, esa fecha fecha, ese producto
                        AND TRIM(BOTH '0' FROM per.nnumide) = TRIM(BOTH '0' FROM x.nif_tomador)
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS THEN
                        n_seg := NULL;
                        n_pro := NULL;
                        d_efe := NULL;
                        n_vig := NULL;
                        n_csituac := NULL;
                  END;
            END;

              --  IF n_vig <> 0
            /*  IF n_csituac IN(2, 3) AND n_seg IS NOT NULL THEN
                 -- FAL. 24/10/2011. Bug 19853 - Rehabilitacion de polizas
                 cerror := pac_rehabilita.f_rehabilita(n_seg, 700, n_cagente, n_mov);

                 IF cerror <> 0 THEN
                    p_deserror := 'Error en la rehabilitación';
                    cerror := 9001557;
                    RAISE errdatos;
                 ELSE
                     RETURN 4;   -- FAL. aólo rehabilita. No genera suplemento.
                 END IF;
              END IF;*/
            RETURN 4;   -- FAL. aólo rehabilita. No genera suplemento.
         --v_haysuplementos := 1;
         END IF;
      END IF;

      IF v_haysuplementos = 0 THEN
         p_deserror := 'La póliza ' || TO_CHAR(x.poliza_participe)
                       || ' no tiene modificaciones';
         cerror := 107804;
         n_aux := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 2, 1, n_seg,

                               -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                               x.poliza_participe,   -- Fi Bug 14888
                               -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                               x.ncarga   -- Fi Bug 16324
                                       );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
         RETURN 4;   -- marcalo como ok
      END IF;

      --
      v_poliza_rga := x.poliza_participe;
      vtraza := 1000;
      cerror := 0;
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;
      vtraza := 1010;

      IF LTRIM(v_poliza_rga) IS NULL THEN
         p_deserror := 'Número póliza sin informar';
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      v_sproduc := pac_cargas_rga.f_buscavalor('CRT_PRODRGA', x.producto);

      IF v_sproduc IS NULL THEN
         p_deserror := 'Producto desconocido';
         cerror := 104347;
         RAISE errdatos;
      END IF;

      BEGIN
         SELECT sseguro, sproduc, fefecto,
                f_vigente(sseguro, NULL,
                          GREATEST(TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'), fefecto)),
                fcarpro, cforpag, fvencim, cagente, csituac
           INTO n_seg, n_pro, d_efe,
                n_vig,
                d_efepro, v_cforpag, vfvencim, n_cagente, n_csituac
           FROM seguros
          WHERE cpolcia = v_poliza_rga
            AND sproduc = v_sproduc;

         BEGIN
            IF NVL(n_cagente, -1) <> NVL(TO_NUMBER(x.oficina_gestora), -1) THEN
               -- si la oficina gestora es diferente al cargada en la póliza
               p_deserror := 'La póliza ' || TO_CHAR(v_poliza_rga)
                             || ' ha cambiado de oficina. Anterior ' || n_cagente || ' por '
                             || x.oficina_gestora;
               cerror := 9000815;
               n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT seg.sseguro, sproduc, fefecto, 0,   -- es un alta
                                                       csituac, fcarpro, cforpag, fvencim,
                      seg.cagente
                 INTO n_seg, n_pro, d_efe, n_vig, n_csituac, d_efepro, v_cforpag, vfvencim,
                      n_cagente
                 FROM seguros seg, tomadores tom, per_personas per
                WHERE fefecto = TO_DATE(x.fec_efecto, 'dd/mm/rrrr')
                  AND sproduc = v_sproduc
                  AND tom.sseguro = seg.sseguro
                  AND per.sperson = tom.sperson
                  AND cpolcia IS NULL
                  -- cualquier tomador con ese nif, esa fecha fecha, ese producto
                  AND TRIM(BOTH '0' FROM per.nnumide) = TRIM(BOTH '0' FROM x.nif_tomador)
                  AND ROWNUM = 1;

               -- si encuentro la poliza aqui significa que la tengo que eimtir primero
               IF n_csituac = 4 THEN
                  cerror := f_emitir_propuesta(n_seg, p_deserror, x.proceso);

                  IF cerror <> 0 THEN
                     p_deserror := 'Error emitiendo la póliza: ' || v_poliza_rga;
                     RAISE errdatos;
                  END IF;
               ELSE
                  p_deserror := 'Número póliza en estado incorrecto: ' || v_poliza_rga;
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
         WHEN OTHERS THEN
            n_seg := NULL;
            n_pro := NULL;
            d_efe := NULL;
            n_vig := NULL;
      END;

      IF n_seg IS NULL THEN
         p_deserror := 'Número póliza no existe (modificación): ' || v_poliza_rga;
         cerror := 100500;
         RAISE errdatos;
      END IF;

       -- IF n_vig <> 0 THEN
        --   p_deserror := 'Póliza no esta vigente: ' || n_vig;
        --   cerror := 120129;
        --   RAISE errdatos;
       -- END IF;
      -- IF n_vig <> 0 THEN   -- No permita modificar la poliza si no esta vigente
      IF n_csituac IN(2, 3) THEN
         -- FAL. 24/10/2011. Bug 19853 - Rehabilitacion de polizas
         cerror := pac_rehabilita.f_rehabilita(n_seg, 700, n_cagente, n_mov);

         IF cerror <> 0 THEN
            p_deserror := 'Error en la rehabilitación';
            cerror := 9001557;
            RAISE errdatos;
         ELSE
            -- si tiene fecha de vencimiento la borro para que el suplemento no de problemas
            UPDATE seguros
               SET fvencim = NULL
             WHERE sseguro = n_seg
               AND fvencim IS NOT NULL;

            COMMIT;
            vfvencim := NULL;
         END IF;
/*
         p_deserror := 'La póliza ' || TO_CHAR(v_poliza_rga) || ' no esta vigente';
         cerror := 101483;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 2, 1, n_seg,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
         RETURN 2;   -- marcalo como warning
*/
      END IF;

      vtraza := 1020;

      --d_sup := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'); ICV

      /*Cosas a mirar para fechas y tipo movimiento*/
         /* Si prima_anualizada <> suma(iprianu) garanseg y no está en periodo de renovación me creo que es un
            suplemento. Cojo fecha inicio del periodo.
            Sino es una cartera y cojo dia efecto / mes año del periodo
            Al generar el recibo si el último movimiento no es de cartera marco el recibo como suplemento

            Revisando descubrimos que la fecha de efecto es la fecha de última renovación
            */
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
         d_sup := x.fec_inicio_periodo;
      ELSE
         nmeses := CEIL(MONTHS_BETWEEN(x.fec_inicio_periodo, x.fec_efecto));
         d_sup := ADD_MONTHS(x.fec_efecto, nmeses);

         /*d_sup := TO_DATE(TO_CHAR(TO_DATE(x.fec_efecto, 'dd/mm/rrrr'), 'dd/')
                          || TO_CHAR(TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr'), 'mm/rrrr'),
                          'dd/mm/rrrr');*/
         IF d_sup IS NULL THEN
            d_sup := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr');
         END IF;
      END IF;

      IF vfvencim IS NOT NULL THEN
         IF vfvencim <= d_sup THEN
            d_sup := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr');

            IF vfvencim = d_sup THEN
               d_sup := d_sup - 1;   -- si fecha vencimiento = f_sup = fecha_inicio periodo
            END IF;
         END IF;
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

      vfcaranu := NULL;

      IF x.fec_efecto IS NOT NULL THEN
         IF v_movcart = 1 THEN
            vfcaranu := ADD_MONTHS(x.fec_efecto, 12);
         END IF;

         IF d_efepro < d_sup THEN
            IF v_cforpag = 0 THEN   --unica
               vfcarpro := TO_DATE(d_sup, 'dd/mm/rrrr');
            ELSIF v_cforpag = 1 THEN   --anual
               vfcarpro := ADD_MONTHS(TO_DATE(d_sup, 'dd/mm/rrrr'), 12);
            ELSIF v_cforpag = 2 THEN   --semestral
               vfcarpro := ADD_MONTHS(TO_DATE(d_sup, 'dd/mm/rrrr'), 6);
            ELSIF v_cforpag = 3 THEN   --cuatrimestral
               vfcarpro := ADD_MONTHS(TO_DATE(d_sup, 'dd/mm/rrrr'), 4);
            ELSIF v_cforpag = 4 THEN   --trimestral
               vfcarpro := ADD_MONTHS(TO_DATE(d_sup, 'dd/mm/rrrr'), 3);
            ELSIF v_cforpag = 6 THEN   --bimestral
               vfcarpro := ADD_MONTHS(TO_DATE(d_sup, 'dd/mm/rrrr'), 2);
            ELSIF v_cforpag = 12 THEN   --mensual
               vfcarpro := ADD_MONTHS(TO_DATE(d_sup, 'dd/mm/rrrr'), 1);
            END IF;

            UPDATE seguros
               SET fcarant = d_sup,
                   fcarpro = vfcarpro,
                   fcaranu = NVL(vfcaranu, fcaranu)
             WHERE sseguro = n_seg;
         END IF;
      ELSE   -- jlb -- tengo que hacer el suplemento....
         UPDATE seguros
            SET   --fcarant = d_sup,
               fcarpro = d_sup
          --fcaranu = nvl(vfcaranu, fcaranu)
         WHERE  sseguro = n_seg;
      END IF;

    --  COMMIT;   -- es necesario el commit? en principio con el NOPRAGMA de inicializar suplemento ya n oes necesario
--------------------------------------------------------------------------
-- iniciar suple
--------------------------------------------------------------------------
      vtraza := 1030;
      cerror := p_iniciar_suple(n_seg, d_sup, k_motivomodif, n_est, n_mov, p_deserror);

      IF cerror <> 0 THEN
         RAISE errdatos;
      END IF;

--------------------------------------------------------------------------
-- modificacions
--------------------------------------------------------------------------
      vtraza := 1045;
      -- FAL - 31/10/2010 - Bug 19926: CRT002 - Suplemento Cambio de tomador en las cargas (RGA)
      v_haycambio_tomador := 0;

      SELECT COUNT('x')
        INTO v_haycambio_tomador
        FROM (SELECT NVL(x.nif_tomador, 0)
                FROM DUAL
              MINUS
              SELECT nnumide
                FROM per_personas per, tomadores est
               WHERE per.sperson = est.sperson
                 AND est.nordtom = 1
                 AND est.sseguro = n_seg);

      --SELECT NVL(nif_tomador, 0)
       -- FROM int_rga
       --WHERE poliza_participe = x.poliza_participe
        -- AND producto = x.producto
         --AND proceso = (SELECT MAX(proceso)
           --               FROM int_rga
             --            WHERE poliza_participe = x.poliza_participe
               --            AND producto = x.producto
                 --          AND proceso < x.proceso));
      IF v_haycambio_tomador > 0 THEN
         -- busqueda en host
         v_ncarga := f_next_carga;
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
                        (ncarga, seqlog, fecha,
                         mig_pk, tipo,
                         incid)
                 VALUES (v_ncarga, v_seq, f_sysdate,
                         v_ncarga || '-' || x.poliza_participe || '-' || x.producto, 'W',
                         'psinterf: ' || psinterf || 'Busqueda persona en Host: ' || pterror);
         END IF;

         -- alta de la persona tomador
         v_mig_personas.ncarga := v_ncarga;
         v_mig_personas.cestmig := 1;
         v_mig_personas.mig_pk := v_ncarga || '/' || x.nif_tomador;
         v_mig_personas.idperson := 0;
         v_mig_personas.snip := x.nif_tomador;
         vtraza := 1050;
         v_mig_personas.ctipide := 27;   --nif carga fichero (detvalor 672);
         v_mig_personas.ctipide := NVL(reg_dat_pers.ctipdoc, v_mig_personas.ctipide);
         -- Bug 0017569
         v_mig_personas.cestper := 0;   -- operativa
         v_mig_personas.nnumide := x.nif_tomador;
         v_mig_personas.cpertip := NVL(reg_dat_pers.ctipper, 1);
         v_mig_personas.swpubli := 0;
         v_mig_personas.csexper := NULL;
         v_mig_personas.fnacimi := NVL(reg_dat_pers.fnacimi, x.fec_nac_tomador);

         -- Bug 0017569

         -- Bug 0016525. 03/11/2010. FAL. Asignar agente según especificaciones
         -- v_mig_personas.cagente := x.caja_gestora;
         IF x.caja_gestora IS NULL THEN
            v_mig_seg.cagente := SUBSTR(x.cuenta_corriente, 5, 4);
            v_mig_personas.cagente := ff_agente_cpervisio(SUBSTR(x.cuenta_corriente, 5, 4));

            IF v_mig_seg.cagente IN(106, 900, 9008, 9208, 9981, 9221, 9205) THEN
               v_mig_seg.cagente := 9999;
               v_mig_personas.cagente := 9999;
            END IF;
         ELSIF x.caja_gestora = '3081' THEN
            IF x.oficina_gestora = 'AGE8' THEN
               v_mig_seg.cagente := k_agente;
               v_mig_personas.cagente := NVL(ff_agente_cpervisio(k_agente), k_agente);
               cerror := 700145;
               p_deserror := 'x.oficina_gestora = AGE8';
               n_aux :=
                  p_marcalinea
                     (x.proceso, x.nlinea, x.tipo_oper, 2, 0, NULL,
                      -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      x.poliza_participe,   -- Fi Bug 14888
                                            -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      x.ncarga   -- Fi Bug 16324
                              );
               n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
            ELSE
               v_mig_seg.cagente := x.oficina_gestora;
               v_mig_personas.cagente := ff_agente_cpervisio(x.oficina_gestora);

               IF v_mig_seg.cagente IN(106, 900, 9008, 9208, 9981, 9221, 9205) THEN
                  v_mig_seg.cagente := 9999;
                  v_mig_personas.cagente := 9999;
               END IF;
            END IF;
         ELSE
            v_mig_seg.cagente := x.caja_gestora;
            v_mig_personas.cagente := ff_agente_cpervisio(x.caja_gestora);
         END IF;

         v_mig_personas.cagente := ff_agente_cpervisio(NVL(reg_dat_pers.cagente,
                                                           v_mig_personas.cagente));
         -- Bug 0017569
            -- Fi Bug 0016525
         vtraza := 1070;

         IF x.nombre_tomador IS NULL THEN
            b_warning := TRUE;
            p_genera_logs(vobj, vtraza, 'Nombre tomador',
                          'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                          x.proceso,
                          'Nombre tomador Campo vacio ' || ' (' || x.proceso || '-'
                          || x.nlinea || ')');
            x.nombre_tomador := ' ';
         END IF;

         IF x.apellidos_tomador IS NOT NULL THEN
            IF INSTR(x.apellidos_tomador, ' ') = 0 THEN
               v_tapelli1 := x.apellidos_tomador;
               v_tapelli2 := NULL;
            ELSE
               v_tapelli1 := SUBSTR(x.apellidos_tomador, 1,
                                    INSTR(x.apellidos_tomador, ' ') - 1);
               v_tapelli2 := SUBSTR(x.apellidos_tomador, INSTR(x.apellidos_tomador, ' ') + 1,
                                    LENGTH(x.apellidos_tomador));
            END IF;
         END IF;

         vtraza := 1075;
         v_mig_personas.tapelli1 := NVL(v_tapelli1, x.nombre_tomador);

         IF x.apellidos_tomador IS NULL THEN
            v_mig_personas.tnombre := NULL;
         ELSE
            v_mig_personas.tnombre := x.nombre_tomador;
         END IF;

         v_mig_personas.tapelli2 := v_tapelli2;
         -- Direccion Particular
         v_mig_personas.ctipdir := 1;
         -- Bug 0016324. FAL. 18/10/2010
         --v_mig_personas.tnomvia := x.direccion_tomador;
         v_mig_personas.tnomvia := SUBSTR(x.direccion_tomador, 1, 40);
         -- Fi Bug 0016324
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

         IF x.cp_tomador IS NULL THEN
            b_warning := TRUE;
            p_genera_logs(vobj, vtraza, 'Código postal',
                          'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                          x.proceso,
                          'Código postal Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                          || ')');
            v_mig_personas.cpostal := NULL;
         ELSE
            v_mig_personas.cpostal := LPAD(x.cp_tomador, 5, '0');
         END IF;

         v_mig_personas.cpostal := NVL(reg_dat_dir.cpostal, v_mig_personas.cpostal);
         -- Bug 0017569
         vtraza := 1095;

         BEGIN
            -- Bug 0016525.03/11/2010.FAL
            IF x.poblacion_tomador IS NULL THEN
               b_warning := TRUE;
               p_genera_logs(vobj, vtraza, 'localidad',
                             'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                             x.proceso,
                             'localidad Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                             || ')');
               v_mig_personas.cprovin := NULL;
               v_mig_personas.cpoblac := NULL;
            ELSE
               DECLARE
                  v_localidad    VARCHAR2(200);

                  CURSOR c1 IS
                     SELECT DISTINCT b.cprovin, b.cpoblac
                                FROM codpostal c, poblaciones b, provincias a
                               WHERE a.cpais = v_mig_personas.cpais
                                 --cprovin = v_mig_personas.cprovin
                                 AND b.cprovin = a.cprovin
                                 AND(UPPER(b.tpoblac) LIKE UPPER(v_localidad))
                                 AND c.cpostal = LPAD(x.cp_tomador, 5, '0')
                                 AND c.cprovin = a.cprovin
                                 AND c.cpoblac = b.cpoblac
                            ORDER BY 1, 2;
               BEGIN
                  vtraza := 1100;
                  v_localidad := RTRIM(RTRIM(LTRIM(TRANSLATE(UPPER(x.poblacion_tomador),
                                                             'ÁÉÍÓÚ', 'AEIOU'))),
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
                                  WHERE cpostal = LPAD(x.cp_tomador, 5, '0');

                        vnum_err := pac_int_online.f_crear_poblacion(v_localidad,
                                                                     v_mig_personas.cprovin,
                                                                     LPAD(x.cp_tomador, 5, '0'),
                                                                     v_mig_personas.cpoblac);

                        IF vnum_err <> 0 THEN
                           b_warning := TRUE;
                           p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                         'no definido ' || ' (' || x.proceso || '-'
                                         || x.nlinea || '-' || x.poblacion_tomador || '-'
                                         || x.cp_tomador || ')',
                                         x.proceso,
                                         'localidad cod_postal no definido ' || ' ('
                                         || x.proceso || '-' || x.nlinea || '-'
                                         || x.poblacion_tomador || '-' || x.cp_tomador || ')');
                           v_mig_personas.cprovin := NULL;
                           v_mig_personas.cpoblac := NULL;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           BEGIN
                              SELECT SUBSTR(LPAD(x.cp_tomador, 5, '0'), 1, 2)
                                INTO v_mig_personas.cprovin
                                FROM DUAL;

                              vnum_err :=
                                 pac_int_online.f_crear_poblacion(v_localidad,
                                                                  v_mig_personas.cprovin,
                                                                  LPAD(x.cp_tomador, 5, '0'),
                                                                  v_mig_personas.cpoblac);

                              IF vnum_err <> 0 THEN
                                 b_warning := TRUE;
                                 p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                               'no definido ' || ' (' || x.proceso || '-'
                                               || x.nlinea || '-' || x.poblacion_tomador
                                               || '-' || x.cp_tomador || ')',
                                               x.proceso,
                                               'localidad cod_postal no definido ' || ' ('
                                               || x.proceso || '-' || x.nlinea || '-'
                                               || x.poblacion_tomador || '-' || x.cp_tomador
                                               || ')');
                                 v_mig_personas.cprovin := NULL;
                                 v_mig_personas.cpoblac := NULL;
                              END IF;
                           EXCEPTION
                              WHEN OTHERS THEN
                                 b_warning := TRUE;
                                 p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                               'no definido ' || ' (' || x.proceso || '-'
                                               || x.nlinea || '-' || x.poblacion_tomador
                                               || '-' || x.cp_tomador || ')',
                                               x.proceso,
                                               'localidad cod_postal no definido ' || ' ('
                                               || x.proceso || '-' || x.nlinea || '-'
                                               || x.poblacion_tomador || '-' || x.cp_tomador
                                               || ')');
                                 v_mig_personas.cprovin := NULL;
                                 v_mig_personas.cpoblac := NULL;
                           END;
                     END;
                  ELSE
                     CLOSE c1;
                  END IF;
               END;
            END IF;
         -- Fi Bug 0016525
         END;

         v_mig_personas.cprovin := NVL(reg_dat_dir.cprovin, v_mig_personas.cprovin);
         -- Bug 0017569
         v_mig_personas.cpoblac := NVL(reg_dat_dir.cpoblac, v_mig_personas.cpoblac);
         -- Bug 0017569
         vtraza := 1110;
         --v_mig_personas.cidioma := k_idiomaaaxis;
         v_mig_personas.cidioma := NVL(reg_dat_pers.cidioma, k_idiomaaaxis);   -- Bug 0017569
         vtraza := 1115;
         v_mig_personas.tnumtel := NULL;

         IF reg_dat_contac.ctipcon = 1 THEN
            v_mig_personas.tnumtel := NVL(reg_dat_contac.tvalcon, v_mig_personas.tnumtel);
         -- Bug 0017569
         END IF;

         INSERT INTO mig_personas
              VALUES v_mig_personas
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 1, v_mig_personas.mig_pk);

         INSERT INTO mig_cargas
                     (ncarga, cempres, finiorg, ffinorg, ID, estorg)
              VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_PERSONAS', 0);

         pac_mig_axis.p_migra_cargas(x.nlinea, 'M', v_ncarga, 'DEL');

         BEGIN
            SELECT sperson
              INTO wspersonnueva
              FROM per_personas
             WHERE nnumide = x.nif_tomador;
         EXCEPTION
            WHEN OTHERS THEN
               cerror := 105113;
               p_deserror := 'Error ' || SQLCODE || 'No se encuentra la persona creada NIF: '
                             || x.nif_tomador;
               RAISE errdatos;
         END;

-- el update de tomadres se hace en el despues de finalizar suplemento
         -- alta en host
         IF k_busca_host = 1 THEN
            -- FAL. 28/06/2011. Parametrizar la busqueda de personas host
            vnum_err := f_alta_persona_host(x, psinterf, terror);

            IF vnum_err <> 0 THEN
               vnum_err := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 2, 1, NULL,

                                        -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                        x.poliza_participe,   -- Fi Bug 14888
                                        -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                        x.ncarga   -- Fi Bug 16324
                                                );

               IF vnum_err <> 0 THEN
                  --Si fallan estas funciones de gestión salimos del programa
                  RAISE verrorgrab;
               END IF;

               IF NOT warning_alta_host THEN
                  vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, 700145, terror);

                  IF vnum_err <> 0 THEN
                     --Si fallan estas funciones de gestión salimos del programa
                     RAISE verrorgrab;
                  END IF;

                  warning_alta_host := TRUE;
               END IF;
            END IF;
         END IF;
      END IF;

          -- FAL: mirar si cambia el asegurado. No implementado (sólo cambio tomador). Requiere traspaso a tablas EST de per_personas,
          -- despues de pac_mig_axis.f_migra_personas que inserta en las SEG,
          -- para recuperar de ESTassegurats
          -- aun haciendo pac_persona.TRASPASO_TABLAS_PER, da error: PAC_ALCTR126.traspaso_asegurados.Error traspaso tabla ASEGURADOS.- ORA-01400: no se puede realizar una inserción NULL en ("ASEGURADOS"."SPERSON")
          /*
          v_haycambio_asegurado := 0;

          SELECT COUNT('x')
            INTO v_haycambio_asegurado
            FROM (SELECT NVL(x.nif, 0)
                    FROM DUAL
                  MINUS
                  SELECT NVL(nif, 0)
                    FROM int_rga
                   WHERE poliza_participe = x.poliza_participe
                     AND producto = x.producto
                     AND proceso = (SELECT MAX(proceso)
                                      FROM int_rga
                                     WHERE poliza_participe = x.poliza_participe
                                       AND producto = x.producto
                                       AND proceso < x.proceso));

          IF v_haycambio_asegurado > 0 THEN
             -- busqueda en host
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
                            (ncarga, seqlog, fecha,
                             mig_pk, tipo,
                             incid)
                     VALUES (v_ncarga, v_seq, f_sysdate,
                             v_ncarga || '-' || x.poliza_participe || '-' || x.producto, 'W',
                             'psinterf: ' || psinterf || 'Busqueda persona en Host: ' || pterror);
             END IF;

             -- alta de la persona tomador
             v_ncarga := f_next_carga;
             v_mig_personas.ncarga := v_ncarga;
             v_mig_personas.cestmig := 1;
             v_mig_personas.mig_pk := v_ncarga || '/ a /' || x.nif;
             v_mig_personas.idperson := 0;
             v_mig_personas.snip := x.nif;
             vtraza := 1050;
             v_mig_personas.ctipide := 27;   --nif carga fichero (detvalor 672);
             v_mig_personas.ctipide := NVL(reg_dat_pers.ctipdoc, v_mig_personas.ctipide);   -- Bug 0017569
             v_mig_personas.cestper := 0;   -- operativa
             v_mig_personas.nnumide := x.nif;
             v_mig_personas.cpertip := NVL(reg_dat_pers.ctipper, 1);
             v_mig_personas.swpubli := 0;
             v_mig_personas.csexper := NULL;
             v_mig_personas.fnacimi := NVL(reg_dat_pers.fnacimi, x.fec_nac);   -- Bug 0017569

             -- Bug 0016525. 03/11/2010. FAL. Asignar agente según especificaciones
             -- v_mig_personas.cagente := x.caja_gestora;
             IF x.caja_gestora IS NULL THEN
                v_mig_seg.cagente := SUBSTR(x.cuenta_corriente, 5, 4);
                v_mig_personas.cagente := ff_agente_cpervisio(SUBSTR(x.cuenta_corriente, 5, 4));

                IF v_mig_seg.cagente IN(106, 900, 9008, 9208, 9981, 9221, 9205) THEN
                   v_mig_seg.cagente := 9999;
                   v_mig_personas.cagente := 9999;
                END IF;
             ELSIF x.caja_gestora = '3081' THEN
                IF x.oficina_gestora = 'AGE8' THEN
                   v_mig_seg.cagente := k_agente;
                   v_mig_personas.cagente := NVL(ff_agente_cpervisio(k_agente), k_agente);
                   cerror := 700145;
                   p_deserror := 'x.oficina_gestora = AGE8';
                   n_aux :=
                      p_marcalinea
                         (x.proceso, x.nlinea, x.tipo_oper, 2, 0, NULL,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                          x.poliza_participe,   -- Fi Bug 14888
                                                -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                          x.ncarga   -- Fi Bug 16324
                                  );
                   n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 2, cerror, p_deserror);
                ELSE
                   v_mig_seg.cagente := x.oficina_gestora;
                   v_mig_personas.cagente := ff_agente_cpervisio(x.oficina_gestora);

                   IF v_mig_seg.cagente IN(106, 900, 9008, 9208, 9981, 9221, 9205) THEN
                      v_mig_seg.cagente := 9999;
                      v_mig_personas.cagente := 9999;
                   END IF;
                END IF;
             ELSE
                v_mig_seg.cagente := x.caja_gestora;
                v_mig_personas.cagente := ff_agente_cpervisio(x.caja_gestora);
             END IF;

             v_mig_personas.cagente := ff_agente_cpervisio(NVL(reg_dat_pers.cagente,
                                                               v_mig_personas.cagente));   -- Bug 0017569
             -- Fi Bug 0016525
             vtraza := 1070;

             IF x.nombre IS NULL THEN
                b_warning := TRUE;
                p_genera_logs(vobj, vtraza, 'Nombre tomador',
                              'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                              x.proceso,
                              'Nombre tomador Campo vacio ' || ' (' || x.proceso || '-'
                              || x.nlinea || ')');
                x.nombre := ' ';
             END IF;

             IF x.apellidos IS NOT NULL THEN
                IF INSTR(x.apellidos, ' ') = 0 THEN
                   v_tapelli1 := x.apellidos;
                   v_tapelli2 := NULL;
                ELSE
                   v_tapelli1 := SUBSTR(x.apellidos, 1, INSTR(x.apellidos, ' ') - 1);
                   v_tapelli2 := SUBSTR(x.apellidos, INSTR(x.apellidos, ' ') + 1,
                                        LENGTH(x.apellidos));
                END IF;
             END IF;

             vtraza := 1075;
             v_mig_personas.tapelli1 := NVL(v_tapelli1, x.nombre);

             IF x.apellidos IS NULL THEN
                v_mig_personas.tnombre := NULL;
             ELSE
                v_mig_personas.tnombre := x.nombre;
             END IF;

             v_mig_personas.tapelli2 := v_tapelli2;
             -- Direccion Particular
             v_mig_personas.ctipdir := 1;
             -- Bug 0016324. FAL. 18/10/2010
             --v_mig_personas.tnomvia := x.direccion;
             v_mig_personas.tnomvia := SUBSTR(x.direccion, 1, 40);
             -- Fi Bug 0016324
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

             IF x.cp IS NULL THEN
                b_warning := TRUE;
                p_genera_logs(vobj, vtraza, 'Código postal',
                              'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                              x.proceso,
                              'Código postal Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                              || ')');
                v_mig_personas.cpostal := NULL;
             ELSE
                v_mig_personas.cpostal := LPAD(x.cp, 5, '0');
             END IF;

             v_mig_personas.cpostal := NVL(reg_dat_dir.cpostal, v_mig_personas.cpostal);   -- Bug 0017569
             vtraza := 1095;

             BEGIN
                -- Bug 0016525.03/11/2010.FAL
                IF x.poblacion IS NULL THEN
                   b_warning := TRUE;
                   p_genera_logs(vobj, vtraza, 'localidad',
                                 'Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea || ')',
                                 x.proceso,
                                 'localidad Campo vacio ' || ' (' || x.proceso || '-' || x.nlinea
                                 || ')');
                   v_mig_personas.cprovin := NULL;
                   v_mig_personas.cpoblac := NULL;
                ELSE
                   DECLARE
                      v_localidad    VARCHAR2(200);

                      CURSOR c1 IS
                         SELECT DISTINCT b.cprovin, b.cpoblac
                                    FROM codpostal c, poblaciones b, provincias a
                                   WHERE a.cpais = v_mig_personas.cpais
                                     --cprovin = v_mig_personas.cprovin
                                     AND b.cprovin = a.cprovin
                                     AND(UPPER(b.tpoblac) LIKE UPPER(v_localidad))
                                     AND c.cpostal = LPAD(x.cp, 5, '0')
                                     AND c.cprovin = a.cprovin
                                     AND c.cpoblac = b.cpoblac
                                ORDER BY 1, 2;
                   BEGIN
                      vtraza := 1100;
                      v_localidad := RTRIM(RTRIM(LTRIM(TRANSLATE(UPPER(x.poblacion), 'ÁÉÍÓÚ',
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
                                      WHERE cpostal = LPAD(x.cp, 5, '0');

                            vnum_err := pac_int_online.f_crear_poblacion(v_localidad,
                                                                         v_mig_personas.cprovin,
                                                                         LPAD(x.cp, 5, '0'),
                                                                         v_mig_personas.cpoblac);

                            IF vnum_err <> 0 THEN
                               b_warning := TRUE;
                               p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                             'no definido ' || ' (' || x.proceso || '-'
                                             || x.nlinea || '-' || x.poblacion || '-' || x.cp
                                             || ')',
                                             x.proceso,
                                             'localidad cod_postal no definido ' || ' ('
                                             || x.proceso || '-' || x.nlinea || '-' || x.poblacion
                                             || '-' || x.cp || ')');
                               v_mig_personas.cprovin := NULL;
                               v_mig_personas.cpoblac := NULL;
                            END IF;
                         EXCEPTION
                            WHEN OTHERS THEN
                               BEGIN
                                  SELECT SUBSTR(LPAD(x.cp, 5, '0'), 1, 2)
                                    INTO v_mig_personas.cprovin
                                    FROM DUAL;

                                  vnum_err :=
                                     pac_int_online.f_crear_poblacion(v_localidad,
                                                                      v_mig_personas.cprovin,
                                                                      LPAD(x.cp, 5, '0'),
                                                                      v_mig_personas.cpoblac);

                                  IF vnum_err <> 0 THEN
                                     b_warning := TRUE;
                                     p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                                   'no definido ' || ' (' || x.proceso || '-'
                                                   || x.nlinea || '-' || x.poblacion || '-'
                                                   || x.cp || ')',
                                                   x.proceso,
                                                   'localidad cod_postal no definido ' || ' ('
                                                   || x.proceso || '-' || x.nlinea || '-'
                                                   || x.poblacion || '-' || x.cp || ')');
                                     v_mig_personas.cprovin := NULL;
                                     v_mig_personas.cpoblac := NULL;
                                  END IF;
                               EXCEPTION
                                  WHEN OTHERS THEN
                                     b_warning := TRUE;
                                     p_genera_logs(vobj, vtraza, 'localidad cod_postal',
                                                   'no definido ' || ' (' || x.proceso || '-'
                                                   || x.nlinea || '-' || x.poblacion || '-'
                                                   || x.cp || ')',
                                                   x.proceso,
                                                   'localidad cod_postal no definido ' || ' ('
                                                   || x.proceso || '-' || x.nlinea || '-'
                                                   || x.poblacion || '-' || x.cp || ')');
                                     v_mig_personas.cprovin := NULL;
                                     v_mig_personas.cpoblac := NULL;
                               END;
                         END;
                      ELSE
                         CLOSE c1;
                      END IF;
                   END;
                END IF;
             -- Fi Bug 0016525
             END;

             v_mig_personas.cprovin := NVL(reg_dat_dir.cprovin, v_mig_personas.cprovin);   -- Bug 0017569
             v_mig_personas.cpoblac := NVL(reg_dat_dir.cpoblac, v_mig_personas.cpoblac);   -- Bug 0017569
             vtraza := 1110;
             --v_mig_personas.cidioma := k_idiomaaaxis;
             v_mig_personas.cidioma := NVL(reg_dat_pers.cidioma, k_idiomaaaxis);   -- Bug 0017569
             vtraza := 1115;
             v_mig_personas.tnumtel := NULL;

             IF reg_dat_contac.ctipcon = 1 THEN
                v_mig_personas.tnumtel := NVL(reg_dat_contac.tvalcon, v_mig_personas.tnumtel);   -- Bug 0017569
             END IF;

             INSERT INTO mig_personas
                  VALUES v_mig_personas
               RETURNING ROWID
                    INTO v_rowid;

             INSERT INTO mig_pk_emp_mig
                  VALUES (0, v_ncarga, 1, v_mig_personas.mig_pk);

             INSERT INTO mig_cargas
                         (ncarga, cempres, finiorg, ffinorg, ID, estorg)
                  VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

             INSERT INTO mig_cargas_tab_mig
                         (ncarga, tab_org, tab_des, ntab)
                  VALUES (v_ncarga, 'INT_RGA', 'MIG_PERSONAS', 0);

             pac_mig_axis.p_migra_cargas(x.nlinea, 'M', v_ncarga, 'DEL');

             BEGIN
                SELECT sperson
                  INTO wspersonnueva
                  FROM per_personas
                 WHERE nnumide = x.nif;
             EXCEPTION
                WHEN OTHERS THEN
                   cerror := 105113;
                   p_deserror := 'Error ' || SQLCODE || 'No se encuentra la persona creada NIF: '
                                 || x.nif;
                   RAISE errdatos;
             END;

             pac_persona.traspaso_tablas_per(wspersonnueva, wpersfict); -- necesario traspaso a tablas EST de personas para asegurados

             BEGIN
                SELECT NVL(nif, 0)
                  INTO wnif_asegurat_antic
                  FROM int_rga
                 WHERE poliza_participe = x.poliza_participe
                   AND producto = x.producto
                   AND proceso = (SELECT MAX(proceso)
                                    FROM int_rga
                                   WHERE poliza_participe = x.poliza_participe
                                     AND producto = x.producto
                                     AND proceso < x.proceso);

                SELECT norden, sperson
                  INTO w_norden_assegurat_antic, w_sperson_assegurat_antic
                  FROM estassegurats
                 WHERE sseguro = n_est
                   AND sperson = (SELECT sperson
                                    FROM estper_personas
                                   WHERE nnumide = wnif_asegurat_antic);

                UPDATE estassegurats
                   SET sperson = (SELECT sperson
                                    FROM per_personas
                                   WHERE nnumide = x.nif)
                 WHERE sseguro = n_est
                   AND sperson = w_sperson_assegurat_antic
                   AND norden = w_norden_assegurat_antic;

                SELECT sperson
                  INTO w_sperson_assegurat_antic
                  FROM estriesgos
                 WHERE sseguro = n_est
                   AND sperson = (SELECT sperson
                                    FROM estper_personas
                                   WHERE nnumide = wnif_asegurat_antic);

                UPDATE estriesgos
                   SET sperson = (SELECT sperson
                                    FROM per_personas
                                   WHERE nnumide = x.nif)
                 WHERE sseguro = n_est
                   AND sperson = w_sperson_assegurat_antic;
             EXCEPTION
                WHEN OTHERS THEN
                   cerror := 151097;
                   p_deserror := 'Error ' || SQLCODE || 'Ant.asegur: ' || wnif_asegurat_antic
                                 || ' - Nuevo.asegur: ' || x.nif;
                   RAISE errdatos;
             END;

             -- alta en host
             IF k_busca_host = 1 THEN   -- FAL. 28/06/2011. Parametrizar la busqueda de personas host
                vnum_err := f_alta_persona_host(x, psinterf, terror);

                IF vnum_err <> 0 THEN
                   vnum_err :=
                      p_marcalinea
                         (x.proceso, x.nlinea, x.tipo_oper, 2, 1, NULL,   -- Bug 14888. FAL. 11/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                          x.poliza_participe,   -- Fi Bug 14888
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
             END IF;
          END IF;
          */
      --    p_tab_error(f_sysdate, f_user, 'f_modi_poliza', 666, 'sigue suplemento', NULL);

      -- Fi Bug 19926
      IF x.fec_vencimiento IS NOT NULL THEN
         BEGIN
            UPDATE estseguros
               SET fvencim = TO_DATE(x.fec_vencimiento, 'dd/mm/rrrr')
             WHERE sseguro = n_est;
         --AND fvencim <> d_aux;
         EXCEPTION
            WHEN OTHERS THEN
               p_deserror := 'Error ' || SQLCODE || 'Fecha Vencimiento: ' || x.fec_vencimiento;
               cerror := 104566;
               RAISE errdatos;
         END;
      END IF;

      vtraza := 1055;

      IF NVL(TRIM(x.cuenta_corriente), '0') <> '0'
         AND LENGTH(x.cuenta_corriente) >= 20 THEN
         BEGIN
            vtraza := 1065;

            /*  w_cambio_cc := 0;

              SELECT COUNT(*)
                INTO w_cambio_cc
                FROM estseguros
               WHERE sseguro = n_est
                 AND cbancar <> x.cuenta_corriente
                 AND ctipban = 1;*/
            UPDATE estseguros
               SET cbancar = x.cuenta_corriente,
                   ctipban = 1,
                   ctipcob = 2
             WHERE sseguro = n_est;

            IF SQL%ROWCOUNT > 0 THEN
               FOR tom IN (SELECT sperson
                             FROM tomadores tom
                            WHERE sseguro = n_seg
                              AND NOT EXISTS(SELECT 1
                                               FROM per_ccc ccc
                                              WHERE tom.sperson = ccc.sperson
                                                AND ccc.cbancar = x.cuenta_corriente)) LOOP
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
                                     NVL(ff_agente_cpervisio(n_cagente), k_agente), 1,
                                     x.cuenta_corriente, NULL, 0, f_user, f_sysdate, wcnordban);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_deserror := 'Error ' || SQLCODE
                                      || ' insertando cuenta bancaria en persona: '
                                      || x.cuenta_corriente;
                        cerror := 9000777;   -- Error al grabar la cuenta de cargo.
                        RAISE errdatos;
                  END;
               END LOOP;
            END IF;
         EXCEPTION
            WHEN errdatos THEN   -- jlb
               RAISE;
            WHEN OTHERS THEN
               p_deserror := 'Error ' || SQLCODE || ' Cuenta bancaria: ' || x.cuenta_corriente;
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

       --Para agroseguro el cforpag es nulo, mantenemos el actual
      -- IF LTRIM(x.forma_pago) IS NOT NULL THEN
      IF LTRIM(x.forma_pago) IS NOT NULL
         AND LTRIM(x.forma_pago) <> 'E' THEN
         BEGIN
            IF x.forma_pago = 'U' THEN
               v_cforpag := 0;
            ELSE
               v_cforpag := x.forma_pago;
            END IF;

            vtraza := 1090;

            UPDATE estseguros
               SET cforpag = v_cforpag
             WHERE sseguro = n_est
               AND cforpag <> v_cforpag;
         EXCEPTION
            WHEN OTHERS THEN
               p_deserror := 'Error ' || SQLCODE || ' Cuenta forma pago: ' || x.forma_pago;
               cerror := 140704;
               RAISE errdatos;
         END;
      END IF;

      vtraza := 1095;
      vtraza := 1100;

      IF x.imp_capital_final_vida <> 0 THEN
         v_capital := x.imp_capital_final_vida;
      ELSE
         v_capital := x.capital_asegurado;
      END IF;

--      DBMS_OUTPUT.put_line(' round(NVL(ABS(x.prima_neta_anualizada), 0) : '
--                           || NVL(ABS(x.prima_neta_anualizada), 0));
--      DBMS_OUTPUT.put_line(' decode(v_cforpag,0,1) : ' || v_cforpag);
      DECLARE
         v_dummy        NUMBER;
      BEGIN
         SELECT COUNT('1')
           INTO v_dummy
           FROM estgaranseg
          WHERE sseguro = n_est
            AND cgarant = 48
            AND nmovimi = n_mov;
      --   DBMS_OUTPUT.put_line('v_dummy : ' || v_dummy);
      END;

      IF NVL(v_cforpag, 0) = 0 THEN
         UPDATE estgaranseg
            SET icapital = NVL(ABS(x.prima_neta_anualizada), 0),
                iprianu = ABS(x.prima_neta_anualizada),
                ipritar = ABS(x.prima_neta_anualizada),
                ipritot = ABS(x.prima_neta_anualizada),
                icaptot = NVL(ABS(x.prima_neta_anualizada), 0)
          WHERE sseguro = n_est
            AND cgarant IN(48)
            AND nmovimi = n_mov;
      ELSE
         UPDATE estgaranseg
            SET icapital = ROUND(NVL(ABS(x.prima_neta_anualizada), 0) / v_cforpag, 2),
                iprianu = ABS(x.prima_neta_anualizada),
                ipritar = ABS(x.prima_neta_anualizada),
                ipritot = ABS(x.prima_neta_anualizada),
                icaptot = ROUND(NVL(ABS(x.prima_neta_anualizada), 0) / v_cforpag, 2)
          WHERE sseguro = n_est
            AND cgarant IN(48)
            AND nmovimi = n_mov;
      END IF;

      IF x.imp_capital_final_vida <> 0 THEN
         UPDATE estgaranseg
            SET icapital = NVL(v_capital, 0),
                iprianu = 0,
                ipritar = 0,
                ipritot = 0,
                icaptot = NVL(v_capital, 0)
          WHERE sseguro = n_est
            AND cgarant IN(288)
            --En caso de hogar hay más de una garantía el capital asegurado es el contiente
                  -- AND norden = 1
                  -- AND ffinefe IS NULL
            AND nmovimi = n_mov
            AND ROWNUM = 1;
      ELSE
         UPDATE estgaranseg
            SET icapital = NVL(v_capital, 0),
                iprianu = ABS(x.prima_neta_anualizada),   --ABS(v_prima),
                ipritar = ABS(x.prima_neta_anualizada),   --ABS(v_prima),
                ipritot = ABS(x.prima_neta_anualizada),   --ABS(v_prima),
                icaptot = NVL(v_capital, 0)
          WHERE sseguro = n_est
            AND cgarant NOT IN(7706, 7713, 7709, 7710, 48)
            --En caso de hogar hay más de una garantía el capital asegurado es el contiente
                  -- AND norden = 1
                  -- AND ffinefe IS NULL
            AND nmovimi = n_mov
            AND ROWNUM = 1;
      END IF;

      IF NVL(x.capital_2, 0) IS NOT NULL THEN   --Contenido
         UPDATE estgaranseg
            SET icapital = NVL(x.capital_2, 0),
                icaptot = NVL(x.capital_2, 0)
          WHERE sseguro = n_est
            AND cgarant = 7709
            AND nmovimi = n_mov;
      END IF;

      IF NVL(x.capital_3, 0) IS NOT NULL THEN   --Joyas Fuera
         UPDATE estgaranseg
            SET icapital = NVL(x.capital_3, 0),
                icaptot = NVL(x.capital_3, 0)
          WHERE sseguro = n_est
            AND cgarant = 7710
            AND nmovimi = n_mov;
      END IF;

      IF NVL(x.capital_4, 0) IS NOT NULL THEN   --Joyas Dentro
         UPDATE estgaranseg
            SET icapital = NVL(x.capital_4, 0),
                icaptot = NVL(x.capital_4, 0)
          WHERE sseguro = n_est
            AND cgarant = 7713
            AND nmovimi = n_mov;
      END IF;

      IF NVL(x.capital_5, 0) IS NOT NULL THEN   --Objetos de Valor
         UPDATE estgaranseg
            SET icapital = NVL(x.capital_5, 0),
                icaptot = NVL(x.capital_5, 0)
          WHERE sseguro = n_est
            AND cgarant = 7706
            AND nmovimi = n_mov;
      END IF;

      vtraza := 1105;

      --actualizamos la tabla de solicitud de suplementos
      UPDATE sup_solicitud
         SET cestsup = 1
       WHERE sseguro = n_seg
         AND cestsup = 2;

      vtraza := 1107;

-- COMMIT;
--------------------------------------------------------------------------
-- finalitzar suple
--------------------------------------------------------------------------
      INSERT INTO estdetmovseguro
                  (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                   tvalord, cpregun)
           VALUES (n_est, n_mov, k_motivomodif, 0, 0, NULL,
                   'Carga proceso ' || x.proceso || '/' || x.nlinea, 0);

      cerror := p_finalizar_suple(n_est, n_mov, n_seg, p_deserror, k_motivomodif, x.proceso,
                                  d_sup);

      IF cerror <> 0 THEN
         RAISE errdatos;
      END IF;

      --Una vez creado el suplemento creamos el recibo con los datos enviados en caso de cartera
      IF NVL(v_movcart, 0) = 1 THEN
         UPDATE movseguro
            SET cmotmov = 404,
                cmovseg = 2
          WHERE sseguro = n_seg
            AND nmovimi = n_mov
            AND cmotmov = k_motivomodif;
      END IF;

      vtraza := 1110;

      IF wspersonnueva IS NOT NULL THEN
         UPDATE tomadores
            --   SET sperson = (SELECT sperson
              --                  FROM per_personas
               --                WHERE nnumide = x.nif_tomador)
         SET sperson = wspersonnueva,
             cdomici = (SELECT MAX(cdomici)
                          FROM per_direcciones
                         WHERE sperson = wspersonnueva)
          WHERE sseguro = n_seg
            AND nordtom = 1;   -- solo hay un unico tomador
      END IF;

-------------------- FINAL ---------------------
      vtraza := 1190;

      --Cargamos las SEG para la póliza (ncarga)
      IF cerror <> 0 THEN
         vtraza := 1200;
         vnum_err :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         v_i := TRUE;
         vtraza := 1201;
         vnum_err := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, 151840, cerror);

         IF vnum_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
            RAISE errdatos;
         END IF;

         p_deserror := 'Fallo al realizar modificación';
         cerror := 108953;
         RAISE errdatos;
      ELSE
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 4, 1, n_seg,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
      END IF;

      RETURN cerror;
   EXCEPTION
      WHEN verrorgrab THEN
         RETURN 10;
      WHEN errdatos THEN
         ROLLBACK;
         n_aux :=
            p_marcalinea
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
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
               (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                x.poliza_participe,   -- Fi Bug 14888
                                      -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                x.ncarga   -- Fi Bug 16324
                        );
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_modi_poliza;

   FUNCTION f_alta_recibos(x IN OUT int_rga%ROWTYPE, p_deserror IN OUT VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.f_alta_reciboS';
      vtraza         NUMBER;
      cerror         NUMBER;
      errdatos       EXCEPTION;
      n_seg          seguros.sseguro%TYPE;
      n_csituac      seguros.csituac%TYPE;
      n_pro          seguros.sproduc%TYPE;
      n_aux          NUMBER;
      n_mov          movseguro.nmovimi%TYPE;
      d_aux          DATE;
      n_perest       esttomadores.sperson%TYPE;
      n_cagente      seguros.cagente%TYPE;
      b_warning      BOOLEAN;
      v_deswarning   VARCHAR2(1000);
      v_poliza_rga   VARCHAR2(1000);
      v_sproduc      productos.sproduc%TYPE;
      v_cforpag      seguros.cforpag%TYPE;
      v_prima        NUMBER := 0;
       --v_impreal      NUMBER := 0;
      -- v_capital      NUMBER := 0;
      v_comi         NUMBER := 0;
      --Recibo
      v_mig_seg      mig_seguros%ROWTYPE;
      v_mig_rec      mig_recibos%ROWTYPE;
      v_mig_recdet   mig_detrecibos%ROWTYPE;
      vfcaranu       DATE;
      vauxanu        DATE;
      v_ncarga       NUMBER;
      v_seq          NUMBER;
      vnum_err       NUMBER;
      v_rowid        ROWID;
      v_fec_efecto   DATE;
      v_i            BOOLEAN := FALSE;
      v_iprianu      NUMBER := 0;
      v_nrecibo      NUMBER;
      nmeses         NUMBER := 0;
      v_itotalr      NUMBER;
      v_cdelega      NUMBER;
      v_nrecant      NUMBER;
      ssmovrec       NUMBER := 0;
      nnliqmen       NUMBER;
      nnliqlin       NUMBER;
      vagrpro        NUMBER;
      v_cestrec      movrecibo.cestrec%TYPE;
      v_imp_rec_recurrentes_emitidos NUMBER;
      v_imp_rec_produccion_emitidos NUMBER;
      v_imp_rec_produccion_anulados NUMBER;
      v_imp_rec_cartera_emitidos NUMBER;
      v_imp_rec_cartera_anulados NUMBER;
      v_imp_rec_recurrentes_anulados NUMBER;
      v_tipo_recibo  NUMBER;
      vcramo         seguros.cramo%TYPE;
      wtmp           VARCHAR2(2000);

      FUNCTION f_crea_recibo(
         p_imprecibo IN NUMBER,
         p_impcomisi IN NUMBER,
         p_tiporec IN NUMBER,
         p_nrecibo OUT NUMBER,
         p_recanulac IN NUMBER DEFAULT NULL,
         p_cestado_rec IN NUMBER DEFAULT 1)
         RETURN NUMBER IS
      BEGIN
         --Inicializamos la cabecera de la carga
         vtraza := 1115;
         v_ncarga := f_next_carga;
         vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Recibos', v_seq);
         vtraza := 1120;

         INSERT INTO mig_cargas
                     (ncarga, cempres, finiorg, ffinorg, ID, estorg)
              VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

-------------------- INICI ---------------------
         vtraza := 1125;

         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_SEGUROS', 0);

         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_RECIBOS', 1);

         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_DETRECIBOS', 2);

         vtraza := 1130;
         v_mig_rec.mig_pk := v_ncarga || '-' || x.poliza_participe || '-' || x.producto;
         v_mig_rec.mig_fk := v_mig_rec.mig_pk;
         v_mig_rec.ncarga := v_ncarga;
         v_mig_rec.cestmig := 1;
         --jlb -- por defecto que sea el que llega --v_mig_rec.ctiprec := NULL;
         v_mig_rec.ctiprec := p_tiporec;
         -- Necesitamos informar mig_seguros para join con mig_recibos
         vtraza := 1135;

         SELECT v_ncarga ncarga, -4 cestmig, v_mig_rec.mig_pk mig_pk, v_mig_rec.mig_pk mig_fk,
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
          WHERE sseguro = n_seg;

         vtraza := 1140;

         SELECT MAX(nmovimi)
           INTO n_mov
           FROM movseguro m
          WHERE m.sseguro = n_seg
            AND m.cmovseg <> 52;

         IF n_mov IS NULL THEN
            p_deserror := 'Número movimiento(recibo) no existe: ' || v_poliza_rga;
            cerror := 100500;
            RAISE errdatos;
         END IF;

         vtraza := 1143;

         INSERT INTO mig_seguros
              VALUES v_mig_seg
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

         vtraza := 1145;

         --SI ES UN RECIBO DE ANULACIÓN JUGAMOS CON LA FECHA DE ANULACIÓN
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
            END IF;
         END IF;

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
            AND NVL(x.imp_aport_extraord_neta, 0) = 0 THEN
            --JRH Antes no lo teníamos este campo
                  --JRH 17/02/2011
            v_mig_rec.ctiprec := 4;
         END IF;

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

         -- JLB - nuevo
         IF v_mig_rec.ctiprec IN(0, 3) THEN
            UPDATE seguros
               SET fcarant = fcarpro,
                   fcarpro = v_mig_rec.fvencim
             WHERE sseguro = n_seg;
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
              VALUES (0, v_ncarga, 1, v_mig_rec.mig_pk);

         vtraza := 1160;
         vtraza := 1165;

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
               v_mig_recdet.ncarga := v_ncarga;
               v_mig_recdet.cestmig := 1;
               v_mig_recdet.mig_pk := v_mig_rec.mig_pk || '-'
                                      || LTRIM(TO_CHAR(p_concep, '09'));
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
                    VALUES (0, v_ncarga, 2, v_mig_recdet.mig_pk);
            END;
         BEGIN
            -- Por defecto primer riesgo.
            vtraza := 1180;

            OPEN c_gar;

            FETCH c_gar
             INTO v_gar;

            CLOSE c_gar;

            vtraza := 1185;
            crea_detalle(00, ABS(p_imprecibo) + NVL(ABS(x.importe_descuento_om), 0));
            --> 00-Prima Neta
            crea_detalle(11, ABS(p_impcomisi));   --> 11-Comisión bruta
            crea_detalle(13, ABS(x.importe_descuento_om));   --> Descuento OM
         --crea_detalle(08, x.recargo);   --> 02-Consorcio
         --crea_detalle(04, x.impuestos);   --> 04-Impuesto IPS
         END;

         --

         -------------------- FINAL ---------------------
         vtraza := 1190;
         vtraza := 1193;

         UPDATE int_rga
            SET ncarga = v_ncarga
          WHERE proceso = x.proceso
            AND nlinea = x.nlinea;

         vtraza := 1195;
         x.ncarga := v_ncarga;
         --   COMMIT;
         --TRASPASAMOS A LAS REALES
         pac_mig_axis.p_migra_cargas(x.nlinea, 'M', x.ncarga, 'DEL');

         --Cargamos las SEG para la póliza (ncarga)
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = x.ncarga
                        AND tipo = 'E') LOOP
            --Miramos si ha habido algún error y lo informamos.
            vtraza := 1200;
            vnum_err :=
               p_marcalinea
                  (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.poliza_participe,   -- Fi Bug 14888
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
          WHERE r.sseguro = n_seg
            AND NOT EXISTS(SELECT '1'
                             FROM ctaseguro c
                            WHERE c.sseguro = r.sseguro
                              AND c.nrecibo = r.nrecibo);

         vtraza := 1199;
         RETURN 0;   --ok
      END;   -- f_crea_recibo

-- recibo de comisión sobre provision matematica de la compañia de vida
      FUNCTION f_crea_recibo_comision(
         p_impcomisi IN NUMBER,
         p_tiporec IN NUMBER,
         p_nrecibo OUT NUMBER,
         p_cestado_rec IN NUMBER DEFAULT 1)
         RETURN NUMBER IS
      BEGIN
         --Inicializamos la cabecera de la carga
         vtraza := 4115;
         v_ncarga := f_next_carga;
         vnum_err := f_ins_mig_logs_emp(v_ncarga, 'Inicio', 'I', 'Carga Recibos', v_seq);
         vtraza := 4120;

         INSERT INTO mig_cargas
                     (ncarga, cempres, finiorg, ffinorg, ID, estorg)
              VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, x.nlinea, 'OK');

-------------------- INICI ---------------------
         vtraza := 4125;

         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_SEGUROS', 0);

         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_RECIBOS', 1);

         INSERT INTO mig_cargas_tab_mig
                     (ncarga, tab_org, tab_des, ntab)
              VALUES (v_ncarga, 'INT_RGA', 'MIG_DETRECIBOS', 2);

         vtraza := 4130;
         v_mig_rec.mig_pk := v_ncarga || '-' || x.poliza_participe || '-' || x.producto;
         v_mig_rec.mig_fk := v_mig_rec.mig_pk;
         v_mig_rec.ncarga := v_ncarga;
         v_mig_rec.cestmig := 1;
         --jlb -- por defecto que sea el que llega --v_mig_rec.ctiprec := NULL;
         v_mig_rec.ctiprec := p_tiporec;
         -- Necesitamos informar mig_seguros para join con mig_recibos
         vtraza := 4135;

         SELECT v_ncarga ncarga, -4 cestmig, v_mig_rec.mig_pk mig_pk, v_mig_rec.mig_pk mig_fk,
                cagente, npoliza, ncertif, fefecto,
                creafac, cactivi, ctiprea, cidioma,
                cforpag, cempres, sproduc, casegur,
                nsuplem, sseguro, 0 sperson, cagrpro
           INTO v_mig_seg.ncarga, v_mig_seg.cestmig, v_mig_seg.mig_pk, v_mig_seg.mig_fk,
                v_mig_seg.cagente, v_mig_seg.npoliza, v_mig_seg.ncertif, v_mig_seg.fefecto,
                v_mig_seg.creafac, v_mig_seg.cactivi, v_mig_seg.ctiprea, v_mig_seg.cidioma,
                v_mig_seg.cforpag, v_mig_seg.cempres, v_mig_seg.sproduc, v_mig_seg.casegur,
                v_mig_seg.nsuplem, v_mig_seg.sseguro, v_mig_seg.sperson, vagrpro
           FROM seguros
          WHERE sseguro = n_seg;

         vtraza := 4140;

         SELECT MAX(nmovimi)
           INTO n_mov
           FROM movseguro m
          WHERE m.sseguro = n_seg
            AND m.cmovseg <> 52;

         IF n_mov IS NULL THEN
            p_deserror := 'Número movimiento(recibo) no existe: ' || v_poliza_rga;
            cerror := 100500;
            RAISE errdatos;
         END IF;

         vtraza := 4143;

         INSERT INTO mig_seguros
              VALUES v_mig_seg
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 0, v_mig_seg.mig_pk);

         vtraza := 4145;
         --SI ES UN RECIBO DE ANULACIÓN JUGAMOS CON LA FECHA DE ANULACIÓN
         v_mig_rec.ctiprec := 5;
         v_mig_rec.fefecto := TO_DATE(x.fec_inicio_periodo, 'dd/mm/rrrr');

         IF v_mig_rec.fefecto IS NULL THEN
            p_deserror := 'Fecha de efecto recibo nula';
            cerror := 1000135;
            RAISE errdatos;
         END IF;

         v_mig_rec.fvencim := TO_DATE(x.fec_fin_periodo, 'dd/mm/rrrr');

         --v_mig_rec.fvencim := TO_DATE(x.fec_fin_periodo, 'dd/mm/rrrr');
         IF v_mig_rec.fvencim IS NULL THEN
            p_deserror := 'Fecha de fin de periodo nula';
            cerror := 1000135;
            RAISE errdatos;
         END IF;

         vtraza := 4150;
         v_mig_rec.femisio := v_mig_rec.fefecto;
         v_mig_rec.nmovimi := n_mov;
         --v_mig_rec.cestrec := 1;
         v_mig_rec.cestrec := p_cestado_rec;
         v_mig_rec.sseguro := 0;

         INSERT INTO mig_recibos
              VALUES v_mig_rec
           RETURNING ROWID
                INTO v_rowid;

         INSERT INTO mig_pk_emp_mig
              VALUES (0, v_ncarga, 1, v_mig_rec.mig_pk);

         vtraza := 1160;
         vtraza := 1165;

         DECLARE
            v_rie          riesgos.nriesgo%TYPE;
            v_gar          garanpro.cgarant%TYPE;

            CURSOR c_gar IS
               SELECT   cgarant
                   FROM garanpro
                  WHERE sproduc = v_sproduc
               --AND ctipgar = 2
               ORDER BY norden;

            PROCEDURE crea_detalle(p_concep IN NUMBER, p_import IN NUMBER) IS
            BEGIN
               vtraza := 14170;
               v_mig_recdet.ncarga := v_ncarga;
               v_mig_recdet.cestmig := 1;
               v_mig_recdet.mig_pk := v_mig_rec.mig_pk || '-'
                                      || LTRIM(TO_CHAR(p_concep, '09'));
               v_mig_recdet.mig_fk := v_mig_rec.mig_pk;
               v_mig_recdet.cconcep := p_concep;
               v_mig_recdet.cgarant := v_gar;
               v_mig_recdet.nriesgo := 1;
               v_mig_recdet.iconcep := ABS(p_import);
               v_mig_recdet.nmovima := 1;
               vtraza := 4175;

               INSERT INTO mig_detrecibos
                    VALUES v_mig_recdet
                 RETURNING ROWID
                      INTO v_rowid;

               INSERT INTO mig_pk_emp_mig
                    VALUES (0, v_ncarga, 2, v_mig_recdet.mig_pk);
            END;
         BEGIN
            -- Por defecto primer riesgo.
            vtraza := 1180;

            OPEN c_gar;

            FETCH c_gar
             INTO v_gar;

            CLOSE c_gar;

            vtraza := 1185;
            crea_detalle(11, p_impcomisi);   --> 11-Comisión bruta
         END;

         --

         -------------------- FINAL ---------------------
         vtraza := 4193;

         UPDATE int_rga
            SET ncarga = v_ncarga
          WHERE proceso = x.proceso
            AND nlinea = x.nlinea;

         vtraza := 4195;
         x.ncarga := v_ncarga;
         --   COMMIT;
         --TRASPASAMOS A LAS REALES
         pac_mig_axis.p_migra_cargas(x.nlinea, 'M', x.ncarga, 'DEL');

         --Cargamos las SEG para la póliza (ncarga)
         FOR reg IN (SELECT *
                       FROM mig_logs_axis
                      WHERE ncarga = x.ncarga
                        AND tipo = 'E') LOOP
            --Miramos si ha habido algún error y lo informamos.
            vtraza := 4200;
            vnum_err :=
               p_marcalinea
                  (x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,
                   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                   x.poliza_participe,   -- Fi Bug 14888
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
          WHERE r.sseguro = n_seg;

         vtraza := 4199;
         RETURN 0;   --ok
      END f_crea_recibo_comision;   -- f_crea_recibo_comision
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
   BEGIN
      IF
          /* -- jlb ya no me baso en el numero de recibos si no en importes
          NVL(x.num_rec_produccion_emitidos, 0) = 0
         AND NVL(x.num_rec_produccion_anulados, 0) = 0
         AND NVL(x.num_rec_cartera_emitidos, 0) = 0
         AND NVL(x.num_rec_cartera_anulados, 0) = 0
         AND NVL(x.num_rec_recurrentes_emitidos, 0) = 0
         AND NVL(x.num_rec_recurrentes_anulados, 0) = 0*/
         NVL(x.importe_emitidos_prod, 0) = 0
         AND NVL(x.importe_anulados_prod, 0) = 0
         AND NVL(x.importe_emitidos_cart, 0) = 0
         AND NVL(x.importe_anulados_cart, 0) = 0
         AND NVL(x.importe_emitidos_recur, 0) = 0
         AND NVL(x.importe_anulados_recur, 0) = 0
         --JRH 17/02/2011
         AND NVL(x.imp_aport_extraord_neta, 0) = 0
         AND NVL(x.traspasos_entrada, 0) = 0
         --AND NVL(x.traspaso_entrada_rga, 0) = 0 -- llega todo en traspaso de entrada
         AND NVL(x.traspasos_internos_ent, 0) = 0
         AND(x.empresa = 12
             AND NVL(x.comision_respu, 0) = 0)   -- comision sobre vida
         AND(x.empresa = 13
             AND NVL(x.com_produccion_cobros, 0) - NVL(x.com_produccion_devoluciones, 0) = 0)
                                                                                             -- comision sobre pensiones
                                                                                                                                                                                    --JRH 17/02/2011
      THEN
         RETURN 4;   -- no hay nada que tratar
      END IF;

      v_imp_rec_produccion_emitidos := x.importe_emitidos_prod;
      v_imp_rec_produccion_anulados := x.importe_anulados_prod;
      v_imp_rec_cartera_emitidos := x.importe_emitidos_cart;
      v_imp_rec_cartera_anulados := x.importe_anulados_cart;
      v_imp_rec_recurrentes_emitidos := x.importe_emitidos_recur;
      v_imp_rec_recurrentes_anulados := x.importe_anulados_recur;
      v_poliza_rga := x.poliza_participe;
      vtraza := 1000;
      cerror := 4;   -- ok
      p_deserror := NULL;
      b_warning := FALSE;
      v_deswarning := NULL;
      vtraza := 1010;

      IF LTRIM(v_poliza_rga) IS NULL THEN
         p_deserror := 'Número póliza sin informar';
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1015;
      v_sproduc := pac_cargas_rga.f_buscavalor('CRT_PRODRGA', x.producto);

      IF v_sproduc IS NULL THEN
         p_deserror := 'Producto desconocido';
         cerror := 104347;
         RAISE errdatos;
      END IF;

      vtraza := 1017;

      BEGIN
         SELECT sseguro, cforpag, cagrpro, csituac, cramo
           INTO n_seg, v_cforpag, vagrpro, n_csituac, vcramo
           FROM seguros
          WHERE cpolcia = v_poliza_rga
            AND sproduc = v_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            n_seg := NULL;
      END;

      vtraza := 1018;

      IF n_seg IS NULL THEN
         p_deserror := 'Número póliza(recibo) no existe: ' || v_poliza_rga;
         cerror := 100500;
         RAISE errdatos;
      END IF;

      vtraza := 1095;

      --Anulados
      BEGIN
         SELECT DECODE(r.ctiprec, 9, -v.itotalr, v.itotalr), r.cdelega, r.nrecibo, m.cestrec
           INTO v_itotalr, v_cdelega, v_nrecant, v_cestrec
           FROM recibos r, vdetrecibos v, movrecibo m
          WHERE r.sseguro = n_seg
            AND r.nrecibo = v.nrecibo
            AND m.nrecibo = r.nrecibo
            AND m.fmovfin IS NULL
            --  AND m.cestrec = 1 -- segun el estado del recibo haremos una accion o otra
            AND r.nrecibo = (SELECT MAX(nrecibo)
                               FROM recibos r2
                              WHERE r2.sseguro = r.sseguro);
      EXCEPTION
         WHEN OTHERS THEN
            v_itotalr := NULL;
            v_cdelega := NULL;
            v_nrecant := NULL;
            v_cestrec := NULL;
      END;

      vtraza := 2000;
      v_nrecibo := NULL;   -- BORRO EL RECIBO CREADO

      --IF NVL(x.num_rec_produccion_anulados, 0) <> 0 THEN
      IF NVL(x.importe_anulados_prod, 0) <> 0 THEN
         --17/05/2011 IF NVL(v_itotalr, 0) = ABS(x.importe_anulados_prod)
         IF NVL(v_itotalr, 0) = x.importe_anulados_prod
            AND v_cestrec = 1 THEN
            -- jlb

            -- si poliza vigente lo dejamos a pendiente
            cerror := f_movrecibo(v_nrecant, 0, x.fec_inicio_periodo, 2, ssmovrec, nnliqmen,
                                  nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            IF n_csituac <> 0 THEN   -- si la póliza no esta vigente lo anulamos
               cerror := f_movrecibo(v_nrecant, 2, x.fec_inicio_periodo, 2, ssmovrec,
                                     nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0,
                                     NULL);
            END IF;

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            -- jlb -- quito los recibos anulados
            v_imp_rec_produccion_anulados := 0;
         ELSE
            -- jlb
            IF NVL(x.importe_anulados_prod, 0) <> NVL(x.importe_emitidos_prod, 0) THEN
               SELECT DECODE(SIGN(x.importe_anulados_prod), -1, 9, 0)
                 INTO v_tipo_recibo
                 FROM DUAL;

               cerror := f_crea_recibo(x.importe_anulados_prod,
                                       x.com_deveng_produccion_anulaci, v_tipo_recibo,

                                       -- 0  17/02/2011
                                       v_nrecibo, NULL, 2);

               -- jlb emito f_recibo normal y luego lo anulo, no creo ya extornos
               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               --         --JRH Ahorro: ANULACIÓN de recibos
               cerror := f_crea_ctaseguro(x, n_seg, 2, NVL(v_nrecibo, v_nrecant), NULL, NULL,
                                          NULL, NULL, TRUE);

               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               v_imp_rec_produccion_anulados := 0;
            END IF;
         -- end jlb
         END IF;

         vtraza := 2010;
      END IF;

      vtraza := 2011;
      v_nrecibo := NULL;   -- BORRO EL RECIBO CREADO

      --IF NVL(x.num_rec_cartera_anulados, 0) <> 0 THEN
      IF NVL(x.importe_anulados_cart, 0) <> 0 THEN
         -- 17/05/2011 IF NVL(v_itotalr, 0) = ABS(x.importe_anulados_cart)
         IF NVL(v_itotalr, 0) = x.importe_anulados_cart
            AND v_cestrec = 1 THEN
            cerror := f_movrecibo(v_nrecant, 0, x.fec_inicio_periodo, 2, ssmovrec, nnliqmen,
                                  nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            IF n_csituac <> 0 THEN   -- si la póliza esta vigente lo dejamos pendiente
               cerror := f_movrecibo(v_nrecant, 2, x.fec_inicio_periodo, 2, ssmovrec,
                                     nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0,
                                     NULL);
            END IF;

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            v_imp_rec_cartera_anulados := 0;   -- jlb quito de recibos anulados
         ELSE
            -- jlb
            IF NVL(x.importe_anulados_cart, 0) <> NVL(x.importe_emitidos_cart, 0) THEN
               SELECT DECODE(SIGN(x.importe_anulados_cart), -1, 9, 0)
                 INTO v_tipo_recibo
                 FROM DUAL;

               cerror := f_crea_recibo(x.importe_anulados_cart, x.com_deveng_cartera_anulacion,
                                       v_tipo_recibo,   -- 17/05/2011 JLB 0,
                                       v_nrecibo, NULL, 2);

               -- jlb emito f_recibo normal y luego lo anulo, no creo ya extornos
               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               --         --JRH Ahorro: ANULACION de recibos
               cerror := f_crea_ctaseguro(x, n_seg, 2, NVL(v_nrecibo, v_nrecant), NULL, NULL,
                                          NULL, NULL, TRUE);

               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               v_imp_rec_cartera_anulados := 0;
            END IF;
         -- end jlb
         END IF;

         vtraza := 2020;
      END IF;

      vtraza := 2021;
      v_nrecibo := NULL;   -- BORRO EL RECIBO CREADO

      --IF NVL(x.num_rec_recurrentes_anulados, 0) <> 0 THEN
      IF NVL(x.importe_anulados_recur, 0) <> 0 THEN
         -- 17/05/2011 IF NVL(v_itotalr, 0) = ABS(x.importe_anulados_recur)
         IF NVL(v_itotalr, 0) = x.importe_anulados_recur
            AND v_cestrec = 1 THEN
            vtraza := 2022;
            cerror := f_movrecibo(v_nrecant, 0, x.fec_inicio_periodo, 2, ssmovrec, nnliqmen,
                                  nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            vtraza := 2023;

            IF n_csituac <> 0 THEN   -- si la póliza esta vigente lo dejamos pendiente
               cerror := f_movrecibo(v_nrecant, 2, x.fec_inicio_periodo, 2, ssmovrec,
                                     nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0,
                                     NULL);
            END IF;

            vtraza := 2023;

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            v_imp_rec_recurrentes_anulados := 0;
         ELSE
            vtraza := 2024;

            IF NVL(x.importe_anulados_recur, 0) <> NVL(x.importe_emitidos_recur, 0) THEN
               SELECT DECODE(SIGN(x.importe_anulados_recur), -1, 9, 0)
                 INTO v_tipo_recibo
                 FROM DUAL;

               vtraza := 2025;
               cerror := f_crea_recibo(x.importe_anulados_recur, x.com_deveng_recur_anulacion,
                                       v_tipo_recibo,   -- 17/05/2011 0,
                                       v_nrecibo, NULL, 2);

               -- jlb emito f_recibo normal y luego lo anulo, no creo ya extornos
               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               vtraza := 2026;
               --         --JRH Ahorro: Anulacion de recibos <-- Imagino que aqui tambien
               cerror := f_crea_ctaseguro(x, n_seg, 2, NVL(v_nrecibo, v_nrecant), NULL, NULL,
                                          NULL, NULL, TRUE);

               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               v_imp_rec_recurrentes_anulados := 0;
            END IF;
         END IF;

         vtraza := 2030;
      END IF;

      vtraza := 2031;
      --FIN ANULADOS

      -- EMITIDOS
      -- Produccion
      v_nrecibo := NULL;   -- BORRO EL RECIBO CREADO

      -- IF NVL(x.num_rec_produccion_emitidos, 0) <> 0   -- THEN
      IF NVL(x.importe_emitidos_prod, 0) <> 0   -- THEN
         AND NOT(vagrpro IN(2, 21)
                 -- jlb cuenta_seguro -- ESTO NO FUNCIONA continuar
                 --AND NVL(pac_mdpar_productos.f_get_parproducto('CUENTA_SEGURO', v_sproduc), 0) = 1
                 AND vcramo <> 82
                 AND NVL(x.imp_aport_extraord_neta, 0) <> 0) THEN
         -- 17/05/2011 IF NVL(v_itotalr, 0) = ABS(x.importe_emitidos_prod)
         IF NVL(v_itotalr, 0) = x.importe_emitidos_prod
            AND v_cestrec = 0   -- si el recibo esta pendiente
                             THEN
            vtraza := 2032;
            cerror := f_movrecibo(v_nrecant, 1, x.fec_inicio_periodo, 2, ssmovrec, nnliqmen,
                                  nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            cerror := f_crea_ctaseguro(x, n_seg, 2, NVL(v_nrecibo, v_nrecant), NULL, NULL,
                                       NULL, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            -- jlb
            -- 17/05/2011 IF ABS(x.importe_emitidos_prod) = NVL(v_imp_rec_produccion_anulados, 0) THEN
            IF x.importe_emitidos_prod = NVL(v_imp_rec_produccion_anulados, 0) THEN
               -- jlb si me llega el importe como anulado paso el recibo a pendiente o anulado, segun estado póliza
               cerror := f_movrecibo(v_nrecant, 0, x.fec_inicio_periodo, 2, ssmovrec,
                                     nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0,
                                     NULL);

               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               IF n_csituac <> 0 THEN
                  cerror := f_movrecibo(v_nrecant, 2, x.fec_inicio_periodo, 2, ssmovrec,
                                        nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega,
                                        0, NULL);

                  IF cerror <> 0 THEN
                     RAISE errdatos;
                  END IF;
               END IF;
            END IF;
         ELSE
            SELECT DECODE(SIGN(x.importe_emitidos_prod), -1, 9, 0)
              INTO v_tipo_recibo
              FROM DUAL;

            vtraza := 2033;
            cerror := f_crea_recibo(x.importe_emitidos_prod, x.com_deveng_produccion_emision,
                                    v_tipo_recibo,   -- 17/05/2011 0,
                                    v_nrecibo, NULL, 1);   -- jlb emito f_recibo cobrado
            vtraza := 2034;

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            vtraza := 2035;
            cerror := f_crea_ctaseguro(x, n_seg, 2, NVL(v_nrecibo, v_nrecant), NULL, NULL,
                                       NULL, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            -- jlb 17/05/2011 IF ABS(x.importe_emitidos_prod) = NVL(v_imp_rec_produccion_anulados, 0) THEN
            IF x.importe_emitidos_prod = NVL(v_imp_rec_produccion_anulados, 0) THEN
               vtraza := 2036;
               -- jlb si me llega el importe como anulado paso el recibo a pendiente o anulado, segun estado póliza
               cerror := f_movrecibo(v_nrecibo, 0, x.fec_inicio_periodo, 2, ssmovrec,
                                     nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0,
                                     NULL);
               vtraza := 2037;

               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               vtraza := 2038;

               IF n_csituac <> 0 THEN
                  vtraza := 2039;
                  cerror := f_movrecibo(v_nrecibo, 2, x.fec_inicio_periodo, 2, ssmovrec,
                                        nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega,
                                        0, NULL);
                  vtraza := 2040;

                  IF cerror <> 0 THEN
                     RAISE errdatos;
                  END IF;
               END IF;
            END IF;
         END IF;

         vtraza := 2041;
      END IF;

      vtraza := 2042;
      -- fin de producción
      v_nrecibo := NULL;   -- BORRO EL RECIBO CREADO

      --Cartera
      --IF NVL(x.num_rec_cartera_emitidos, 0) <> 0 THEN
      IF NVL(x.importe_emitidos_cart, 0) <> 0 THEN
         -- si el recibo ya existe lo cobramos
         -- 17/05/2011 IF NVL(v_itotalr, 0) = ABS(x.importe_emitidos_cart)
         IF NVL(v_itotalr, 0) = x.importe_emitidos_cart
            AND v_cestrec = 0   -- si el recibo esta pendiente
                             THEN
            cerror := f_movrecibo(v_nrecant, 1, x.fec_inicio_periodo, 2, ssmovrec, nnliqmen,
                                  nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            cerror := f_crea_ctaseguro(x, n_seg, 2, NVL(v_nrecibo, v_nrecant), NULL, NULL,
                                       NULL, NULL, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            -- jlb
            --IF ABS(x.importe_emitidos_cart) = NVL(v_imp_rec_cartera_anulados, 0) THEN
            IF x.importe_emitidos_cart = NVL(v_imp_rec_cartera_anulados, 0) THEN
               -- jlb si me llega el importe como anulado paso el recibo a pendiente o anulado, segun estado póliza
               cerror := f_movrecibo(v_nrecant, 0, x.fec_inicio_periodo, 2, ssmovrec,
                                     nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0,
                                     NULL);

               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               IF n_csituac <> 0 THEN
                  cerror := f_movrecibo(v_nrecant, 2, x.fec_inicio_periodo, 2, ssmovrec,
                                        nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega,
                                        0, NULL);
               END IF;
            END IF;
         ELSE
            SELECT DECODE(SIGN(x.importe_emitidos_cart), -1, 9, 3)
              INTO v_tipo_recibo
              FROM DUAL;

            cerror := f_crea_recibo(x.importe_emitidos_cart, x.com_deveng_cartera_emision,
                                    v_tipo_recibo,   -- 17/05/2011 3,
                                    v_nrecibo, NULL, 1);

            -- jlb emito f_recibo normal y luego lo emito, no creo ya extornos
            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            cerror := f_crea_ctaseguro(x, n_seg, 2, NVL(v_nrecibo, v_nrecant), NULL, NULL,
                                       NULL, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            -- 17/05/2011 IF ABS(x.importe_emitidos_cart) = NVL(v_imp_rec_cartera_anulados, 0) THEN
            IF x.importe_emitidos_cart = NVL(v_imp_rec_cartera_anulados, 0) THEN
               -- jlb si me llega el importe como anulado paso el recibo a pendiente o anulado, segun estado póliza
               cerror := f_movrecibo(v_nrecibo, 0, x.fec_inicio_periodo, 2, ssmovrec,
                                     nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0,
                                     NULL);

               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               IF n_csituac <> 0 THEN
                  cerror := f_movrecibo(v_nrecibo, 2, x.fec_inicio_periodo, 2, ssmovrec,
                                        nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega,
                                        0, NULL);

                  IF cerror <> 0 THEN
                     RAISE errdatos;
                  END IF;
               END IF;
            END IF;
         END IF;

         vtraza := 2430;

         IF NVL(v_cforpag, 0) <> 0 THEN
            SELECT fcaranu
              INTO vfcaranu
              FROM seguros
             WHERE sseguro = n_seg;

            IF vfcaranu IS NOT NULL THEN
               IF TO_CHAR(vfcaranu, 'ddmm') IN('2902') THEN
                  vauxanu := LAST_DAY(TO_DATE('0102' || TO_CHAR(v_mig_rec.fvencim, 'YYYY')));
               END IF;
            END IF;

            UPDATE seguros
               SET   --fcarpro = v_mig_rec.fvencim,
                  --fcarant = v_mig_rec.fefecto,
                  fcarpro = GREATEST(fcarpro, ADD_MONTHS(v_mig_rec.fefecto, 12 / v_cforpag) + 1),
                  fcarant = GREATEST(NVL(fcarant, v_mig_rec.fefecto), v_mig_rec.fefecto),
                  fcaranu = GREATEST(fcaranu, vauxanu)
             WHERE sseguro = n_seg;
         END IF;
      END IF;

      vtraza := 2440;
      -- fin de cartera
      v_nrecibo := NULL;   -- BORRO EL RECIBO CREADO

      --ICV TRATAMIENTO IMPORTE EMITIDOS_RECUR
      -- Recurrentes
      --IF NVL(x.num_rec_recurrentes_emitidos, 0) <> 0 THEN
      IF NVL(x.importe_emitidos_recur, 0) <> 0 THEN
         -- si el recibo ya existe lo cobramos
         -- 17/05/2011 IF NVL(v_itotalr, 0) = ABS(x.importe_emitidos_recur)
         IF NVL(v_itotalr, 0) = x.importe_emitidos_recur
            AND v_cestrec = 0   -- si el recibo esta pendiente
                             THEN
            cerror := f_movrecibo(v_nrecant, 1, x.fec_inicio_periodo, 2, ssmovrec, nnliqmen,
                                  nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            cerror := f_crea_ctaseguro(x, n_seg, 2, NVL(v_nrecibo, v_nrecant), NULL, NULL,
                                       NULL, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            -- jlb
            -- 17/05/2011 IF ABS(x.importe_emitidos_recur) = NVL(v_imp_rec_recurrentes_anulados, 0) THEN
            IF x.importe_emitidos_recur = NVL(v_imp_rec_recurrentes_anulados, 0) THEN
               -- jlb si me llega el importe como anulado paso el recibo a pendiente o anulado, segun estado póliza
               cerror := f_movrecibo(v_nrecant, 0, x.fec_inicio_periodo, 2, ssmovrec,
                                     nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0,
                                     NULL);

               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               IF n_csituac <> 0 THEN
                  cerror := f_movrecibo(v_nrecant, 2, x.fec_inicio_periodo, 2, ssmovrec,
                                        nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega,
                                        0, NULL);

                  IF cerror <> 0 THEN
                     RAISE errdatos;
                  END IF;
               END IF;
            END IF;
         ELSE
            --SELECT DECODE(SIGN(x.importe_emitidos_recur), -1, 9, 1)
            SELECT DECODE(SIGN(x.importe_emitidos_recur), -1, 9, 3)   -- ya no hay suplementos
              INTO v_tipo_recibo
              FROM DUAL;

            cerror := f_crea_recibo(x.importe_emitidos_recur, x.com_deveng_recur_emision,
                                    v_tipo_recibo,   -- 17/05/2011 1,
                                    v_nrecibo, NULL, 1);   -- emito f_recibo

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            cerror := f_crea_ctaseguro(x, n_seg, 2, NVL(v_nrecibo, v_nrecant), NULL, NULL,
                                       NULL, NULL);

            IF cerror <> 0 THEN
               RAISE errdatos;
            END IF;

            -- JLB 17/05/2011 IF ABS(x.importe_emitidos_recur) = NVL(v_imp_rec_recurrentes_anulados, 0) THEN
            IF x.importe_emitidos_recur = NVL(v_imp_rec_recurrentes_anulados, 0) THEN
               -- jlb si me llega el importe como anulado paso el recibo a pendiente o anulado, segun estado póliza
               cerror := f_movrecibo(v_nrecibo, 0, x.fec_inicio_periodo, 2, ssmovrec,
                                     nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega, 0,
                                     NULL);

               IF cerror <> 0 THEN
                  RAISE errdatos;
               END IF;

               IF n_csituac <> 0 THEN
                  cerror := f_movrecibo(v_nrecibo, 2, x.fec_inicio_periodo, 2, ssmovrec,
                                        nnliqmen, nnliqlin, TRUNC(f_sysdate), NULL, v_cdelega,
                                        0, NULL);

                  IF cerror <> 0 THEN
                     RAISE errdatos;
                  END IF;
               END IF;
            END IF;
         END IF;

         vtraza := 2450;
      END IF;

      -- fin de recurrentes
      v_nrecibo := NULL;
      vtraza := 2500;

      --JRH IMP
      IF NVL(x.imp_aport_extraord_neta, 0) <> 0 THEN
         cerror := f_crea_recibo(x.imp_aport_extraord_neta, 0, 4, v_nrecibo);

         -- emito f_recibo
         IF cerror <> 0 THEN
            wtmp := '2510.' || x.imp_aport_extraord_neta || ':' || v_nrecibo;
            vtraza := 2510;
            RAISE errdatos;
         END IF;

         --         --JRH Ahorro: Cobro de recibos
         cerror := f_crea_ctaseguro(x, n_seg, 2, v_nrecibo, NULL, NULL, NULL);

         IF cerror <> 0 THEN
            wtmp := '2520.' || n_seg || ':' || v_nrecibo;
            vtraza := 2520;
            RAISE errdatos;
         END IF;
      END IF;

      IF NVL(x.traspasos_entrada, 0) <> 0 THEN
         -- no creo recibo porque todo llega en emitidos en prod
         IF (vagrpro IN(2, 21)
             -- jlb cuenta_seguro -- ESTO NO FUNCIONA continuar
             --AND NVL(pac_mdpar_productos.f_get_parproducto('CUENTA_SEGURO', v_sproduc), 0) = 1
             AND vcramo <> 82
                             --Bug 27616-XVM-12/09/2013. Se comenta la aportacion extra.
                                             --AND NVL(x.imp_aport_extraord_neta, 0) <> 0
            ) THEN
            cerror := f_crea_recibo(x.traspasos_entrada, 0, 10, v_nrecibo);   -- emito f_recibo

            IF cerror <> 0 THEN
               wtmp := '2530.' || x.traspasos_entrada || ':' || v_nrecibo;
               vtraza := 2530;
               RAISE errdatos;
            END IF;
         END IF;

         --   JRH Ahorro: Cobro de recibos
         cerror := f_crea_ctaseguro(x, n_seg, 2, v_nrecibo, NULL, NULL, NULL);

         IF cerror <> 0 THEN
            wtmp := '2540.' || n_seg || ':' || v_nrecibo;
            vtraza := 2540;
            RAISE errdatos;
         END IF;
      END IF;

--      IF NVL(x.traspaso_entrada_rga, 0) <> 0 THEN
  --       cerror := f_crea_recibo(x.traspaso_entrada_rga, 0, 10, v_nrecibo);   -- emito f_recibo

      --     IF cerror <> 0 THEN
        --      RAISE errdatos;
          -- END IF;

      --         --JRH Ahorro: Cobro de recibos
      --  cerror := f_crea_ctaseguro(x, n_seg, 2, v_nrecibo, NULL, NULL, NULL);

      --IF cerror <> 0 THEN
           --  RAISE errdatos;
          --END IF;
      -- END IF;
      IF NVL(x.traspasos_internos_ent, 0) <> 0 THEN
         cerror := f_crea_recibo(x.traspasos_internos_ent, 0, 10, v_nrecibo);

         -- emito f_recibo
         IF cerror <> 0 THEN
            wtmp := '2550.' || x.traspasos_internos_ent || ':' || v_nrecibo;
            vtraza := 2550;
            RAISE errdatos;
         END IF;

         -- JRH Ahorro: Cobro de recibos
         cerror := f_crea_ctaseguro(x, n_seg, 2, v_nrecibo, NULL, NULL, NULL);

         IF cerror <> 0 THEN
            wtmp := '2560.' || n_seg || ':' || v_nrecibo;
            vtraza := 2560;
            RAISE errdatos;
         END IF;
      END IF;

      IF x.empresa = 12
         AND NVL(x.comision_respu, 0) <> 0 THEN
         cerror := f_crea_recibo_comision(x.comision_respu, 5, v_nrecibo);

         -- creo recibo de comision
         IF cerror <> 0 THEN
            wtmp := '2570.' || x.comision_respu || ':' || v_nrecibo;
            vtraza := 2570;
            RAISE errdatos;
         END IF;
      END IF;

      IF x.empresa = 13
         AND NVL(x.com_produccion_cobros, 0) - NVL(x.com_produccion_devoluciones, 0) <> 0 THEN
         cerror := f_crea_recibo_comision(NVL(x.com_produccion_cobros, 0)
                                          - NVL(x.com_produccion_devoluciones, 0),
                                          5, v_nrecibo);   -- creo recibo de comision

         IF cerror <> 0 THEN
            wtmp := '2580.' || x.com_produccion_cobros || ':' || x.com_produccion_devoluciones
                    || ':' || v_nrecibo;
            vtraza := 2580;
            RAISE errdatos;
         END IF;
      END IF;

         /*for i in 1..nvl(x.num_Rec_produccion_emitidos,0) loop
             cerror := f_crea_recibo(x.importe_emitidos_prod/x.num_Rec_produccion_emitidos, x.com_deveng_produccion_emision/x.num_Rec_produccion_emitidos,0 );  -- emito f_recibo
             if cerror <> 0 then
                 RAISE errdatos;
             end if;
         end loop;

          for i in 1..nvl(x.num_Rec_produccion_anulados,0) loop
             cerror := f_crea_recibo(-1*abs(x.importe_anulados_prod/x.num_Rec_produccion_anulados), x.com_deveng_produccion_anulaci/x.num_Rec_produccion_anulados,0 );  -- emito f_recibo
             if cerror <> 0 then
                 RAISE errdatos;
             end if;
         end loop;

      -- Cartera
         for i in 1..nvl(x.num_Rec_cartera_emitidos,0) loop
             cerror :=  f_crea_recibo(x.importe_emitidos_cart/x.num_Rec_cartera_emitidos, x.com_deveng_cartera_emision/x.num_Rec_cartera_emitidos,1 );  -- emito f_recibo
             if cerror <> 0 then
                 RAISE errdatos;
             end if;
         if nvl(v_cforpag,0) <> 0 then
            UPDATE seguros
            SET   --fcarpro = v_mig_rec.fvencim,
               --fcarant = v_mig_rec.fefecto,
                fcarpro = GREATEST(fcarpro, add_months(v_mig_rec.fefecto,12/v_cforpag) +1),
                fcarant = GREATEST(NVL(fcarant, v_mig_rec.fefecto), v_mig_rec.fefecto),
                fcaranu = GREATEST(fcaranu,
                               TO_DATE(TO_CHAR(fcaranu, 'DDMM')
                                       || TO_CHAR(v_mig_rec.fvencim, 'YYYY'),
                                       'DDMMYYYY'))
               WHERE sseguro = n_seg;
           end if;
         end loop;

         for i in 1..nvl(x.num_Rec_cartera_anulados,0) loop
             cerror := f_crea_recibo(-1*abs(x.importe_anulados_cart/x.num_Rec_cartera_anulados), x.com_deveng_cartera_anulacion/x.num_Rec_cartera_anulados,1);  -- emito f_recibo
             if cerror <> 0 then
                 RAISE errdatos;
             end if;
         end loop ;*/
      vtraza := 3000;
      RETURN 4;   --ok
   EXCEPTION
      WHEN errdatos THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, vtraza, cerror, 'wtmp:' || wtmp);
         -- 22.07.2013.NMM.27616.Informem p_deserror.
         p_deserror := x.proceso || '-' || x.nlinea || ' (traza=' || vtraza || ') ' || SQLCODE
                       || ' ' || SQLERRM;
         pac_cargas_rga.p_genera_logs('f_alta_recibos', vtraza, 'Error:' || cerror,
                                      'Parámetro ' || x.poliza_participe || '-' || 'vnrecibo:'
                                      || v_nrecibo || ' recibo ant' || v_nrecant || ' seg:'
                                      || n_seg,
                                      x.proceso,
                                      'vnrecibo:' || v_nrecibo || ' recibo ant' || v_nrecant
                                      || ' seg:' || n_seg || '-' || SQLCODE);
         n_aux := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,

                               -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                               x.poliza_participe,
                               -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                               x.ncarga);
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, cerror, p_deserror);
         RETURN 1;   -- Error
      WHEN OTHERS THEN
         ROLLBACK;
         p_deserror := x.proceso || '-' || x.nlinea || ' (traza=' || vtraza || ') ' || SQLCODE
                       || ' ' || SQLERRM;
         -- Bug 16324. FAL. 26/10/2010. Registrar linea y error en caso de error
         n_aux := p_marcalinea(x.proceso, x.nlinea, x.tipo_oper, 1, 0, NULL,

                               -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                               x.poliza_participe,
                               -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                               x.ncarga);
         n_aux := p_marcalineaerror(x.proceso, x.nlinea, NULL, 1, SQLCODE, p_deserror);
         -- Fi Bug 16324
         RETURN 10;   -- Error incontrolado
   END f_alta_recibos;

   /*************************************************************************
                                                procedimiento que ejecuta una carga (parte2 proceso).
          param in psproces   : Número proceso
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_ejecutar_carga_proceso(psproces IN NUMBER, p_cproces IN NUMBER)
      -- BUG16130:DRA:15/10/2010
   RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.F_EJECUTAR_CARGA_PROCESO';

      CURSOR polmigra(psproces2 IN NUMBER) IS
         SELECT   a.*
             FROM int_rga a
            WHERE proceso = psproces2
              AND NOT EXISTS(SELECT 1
                               FROM int_carga_ctrl_linea
                              WHERE int_carga_ctrl_linea.sproces = a.proceso
                                AND int_carga_ctrl_linea.nlinea = a.nlinea
                                AND int_carga_ctrl_linea.cestado IN(2, 4, 5))
         --Solo las no procesadas
         --AND empresa in (12,13)
          --AND poliza_participe = '59723'
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
      v_ncarga       NUMBER;
      vsseguro       NUMBER := 0;
      v_cart         NUMBER := 0;
      vffini         DATE;
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
      vffini := f_sysdate;

      IF psproces IS NULL THEN
         vnum_err := 9000505;
         pac_cargas_rga.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err,
                                      'Parámetro psproces obligatorio.', psproces,
                                      f_axis_literales(vnum_err, k_idiomaaaxis) || ':'
                                      || v_tfichero || ' : ' || vnum_err);
         RAISE errorini;
      END IF;

      vtraza := 1;

      SELECT tfichero
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

      vtraza := 3;

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
         vtraza := 5;

         IF NVL(vtiperr, 0) <> 1 THEN
            -- Fi Bug 0016324
            IF x.tipo_oper = 'ALTA' THEN   --Si no esta anulada
               vtraza := 6;
               vterror := NULL;
               -- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
               vtraza := 61;
               verror := f_alta_poliza(x, vterror, wsinterf);

               --Grabamos en las MIG  -- Bug 0016324. FAL. 26/10/2010. Añadimos var. desc. error salida init a NULL
               IF verror IN(0, -2) THEN   --Si ha ido bien o tenemos avisos.
                  IF verror = -2 THEN   -- Avisos.
                     vtraza := 7;
                     vnum_err := p_marcalinea(psproces, x.nlinea, x.poliza_participe, 2, 0,
                                              NULL,
                                              -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                              x.poliza_participe,
                                              -- Fi Bug 14888
                                              -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                              x.ncarga
                                                      -- Fi Bug 16324
                                );

                     IF vnum_err <> 0 THEN
                        --Si fallan esta funciones de gestión salimos del programa
                        RAISE errorini;   --Error que para ejecución
                     END IF;

                     vavisfin := TRUE;
                     verror := 0;
                  END IF;

                  vtraza := 8;
                  vtiperr := f_alta_poliza_seg(x, wsinterf);   --Grabamos en las SEG
                  vtraza := 9;

                  IF vtiperr = 2 THEN
                     vavisfin := TRUE;
                  END IF;

                  IF (x.fec_anulacion IS NOT NULL
                      AND vtiperr IN(4, 2)) THEN
                     vtiperr := f_baja_poliza(x, v_deserror);
                  END IF;

                  vtraza := 10;

                  IF vtiperr IN(0, 4, 2) THEN
                     vtiperr := f_alta_recibos(x, vterror);
                  END IF;

                  --JRH AHORRO
                  IF vtiperr IN(0, 4, 2) THEN
                     vtiperr := f_alta_rentas(x, vterror);
                  END IF;

                  IF vtiperr IN(0, 4, 2) THEN
                     vtiperr := f_alta_siniestros(x, vterror);
                  END IF;

                  IF vtiperr IN(0, 4, 2) THEN
                     vtiperr := f_alta_saldo(x, vterror);
                  END IF;

                  vtraza := 11;

                  -- Bug 0016324. FAL. 18/10/2010.
                  IF vtiperr NOT IN(0, 4, 2) THEN
                     IF k_para_carga <> 1 THEN
                        vtiperr := 4;   -- para que continue con la siguiente linea.
                     ELSE
                        vtiperr := 1;   -- para la carga
                     END IF;
                  ELSIF vtiperr = 2 THEN
                     vavisfin := TRUE;
                  END IF;

                  IF vtiperr = 1 THEN
                     verrorfin := TRUE;
                  END IF;

                  vtraza := 12;
               -- Fi Bug 0016324
               ELSE   --Si ha ido mal el paso a las MIG lo indicamos con el error orbtenido
                  -- Bug 0016324. FAL. 18/10/2010
                  vtraza := 13;
                  vtiperr := 1;
                  -- Fi Bug 0016324
                  vtraza := 20;
                  vnum_err := p_marcalinea(psproces, x.nlinea, x.poliza_participe, 1, 0, NULL,

                                           -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                           x.poliza_participe,
                                           -- Fi Bug 14888
                                           -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                           x.ncarga
                                                   -- Fi Bug 16324
                             );

                  IF vnum_err <> 0 THEN
                     --Si fallan esta funciones de gestión salimos del programa
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  vtraza := 21;
                  vnum_err := p_marcalineaerror(psproces, x.nlinea, NULL, 1, verror,
                                                NVL(vterror, verror));

                  -- Bug 0016324. FAL. 26/10/2010. Registra la desc. error si informada. en caso contrario el literal verror
                  IF vnum_err <> 0 THEN
                     --Si fallan esta funciones de gestión salimos del programa
                     RAISE errorini;   --Error que para ejecución
                  END IF;

                  verrorfin := TRUE;

                  -- Bug 0016324. FAL. 18/10/2010.
                  IF k_para_carga <> 1 THEN
                     -- Fi Bug 0016324
                     vtiperr := 4;   -- para que continue con la siguiente linea.
                  -- Bug 0016324. FAL. 18/10/2010.
                  END IF;
               -- Fi Bug 0016324
               END IF;
            ELSIF x.tipo_oper = 'MODI' THEN
               vtraza := 50;
               --Miramos si creamos un movimiento de cartera o de nueva producción
               --Miramos si viene informado algún importe de cartera, lo que indica que tiene un movimiento de cartera else nueva producción

               -- ICV LO MUEVO DENTRO DE F_MODI_POLIZAS Y CAMBIO CRITERIO
               /*IF x.importe_emitidos_cart <> 0
                  OR x.importe_anulados_cart <> 0 THEN
                  v_cart := 1;
               ELSE
                  v_cart := 0;
               END IF;*/
               vtraza := 51;
               vtiperr := f_modi_poliza(x, v_deserror);
               -- creamos mov de cartera o suplemento
               vtraza := 52;

               IF vtiperr = 2 THEN
                  vavisfin := TRUE;
               END IF;

               IF vtiperr = 1 THEN
                  verrorfin := TRUE;
               END IF;

               IF vtiperr = 0 THEN
                  vtiperr := 4;
               END IF;

               vtraza := 53;

               IF vtiperr IN(0, 4, 2) THEN
                  vtiperr := f_alta_recibos(x, vterror);
               END IF;

               vtraza := 54;

               --JRH AHORRO
               IF vtiperr IN(0, 4, 2) THEN
                  vtiperr := f_alta_rentas(x, vterror);
               END IF;

               IF vtiperr IN(0, 4, 2) THEN
                  vtiperr := f_alta_siniestros(x, vterror);
               END IF;

               IF vtiperr IN(0, 4, 2) THEN
                  vtiperr := f_alta_saldo(x, vterror);
               END IF;

               vnum_err := p_marcalinea(psproces, x.nlinea, x.poliza_participe, vtiperr, 0,
                                        NULL,
                                        -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                                        x.poliza_participe,
                                        -- Fi Bug 14888
                                        -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                                        x.ncarga
                                                -- Fi Bug 16324
                          );

               IF vnum_err <> 0 THEN   --Si fallan esta funciones de gestión salimos del programa
                  p_tab_error
                           (f_sysdate, f_user, vobj, vtraza, vnum_err,
                            'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
                  vnnumlin := NULL;
                  vnum_err := f_proceslin(psproces,
                                          f_axis_literales(180856, k_idiomaaaxis) || ':'
                                          || v_tfichero || ' : ' || vnum_err,
                                          1, vnnumlin);
                  RAISE errorini;   --Error que para ejecución
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
               --JRH Aqui
               vtraza := 56;
            ELSIF x.tipo_oper = 'BAJA' THEN
               vtraza := 70;
               vtiperr := f_baja_poliza(x, v_deserror);

               IF vtiperr = 2 THEN
                  vavisfin := TRUE;
               END IF;

               IF vtiperr IN(0, 4, 2) THEN
                  vtiperr := f_alta_recibos(x, vterror);
               END IF;

               --               --JRH AHORRO
               IF vtiperr IN(0, 4, 2) THEN
                  vtiperr := f_alta_rentas(x, vterror);
               END IF;

               IF vtiperr IN(0, 4, 2) THEN
                  vtiperr := f_alta_siniestros(x, vterror);
               END IF;

               IF vtiperr IN(0, 4, 2) THEN
                  vtiperr := f_alta_saldo(x, vterror);
               END IF;

               -- Bug 0016324. FAL. 18/10/2010.d
               IF vtiperr NOT IN(4, 2) THEN
                  IF k_para_carga <> 1 THEN
                     ROLLBACK;   --deshago los cambios
                     vtiperr := 4;   -- para que continue con la siguiente linea.
                  ELSE
                     vtiperr := 1;   -- para la carga
                  END IF;
               END IF;
            -- Fi Bug 0016324
            ELSIF x.tipo_oper = 'ERR' THEN
               -- JLB - si el primera linea es un ERR sale del proceso por error
               vtiperr := 4;
            END IF;

            IF vtiperr = 1 THEN   --Ha habido error
               verrorfin := TRUE;
               ROLLBACK;
            ELSIF vtiperr = 2 THEN   -- Es un warning
               vavisfin := TRUE;
               COMMIT;
            ELSIF vtiperr = 4 THEN   --Ha ido bien.
               NULL;
               COMMIT;
            ELSE
               RAISE errorini;   --Error que para ejecución(funciones de gestión)
            END IF;

            COMMIT;
         -- Bug 0016324. FAL. 18/10/2010
         ELSIF vtiperr = 1
               AND k_para_carga = 1 THEN
            vtraza := 100;
            vtiperr := 1;
            vcoderror := 151541;
            --Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga
            vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                       vffini,
                                                                       --f_sysdate,  -- jlb CORREGIR!!
                                                                       f_sysdate, vtiperr,
                                                                       p_cproces,
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

      vtraza := 200;
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
      vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero, vffini,

                                                                 --f_sysdate,  -- jlb CORREGIR!!
                                                                 f_sysdate, vtiperr, p_cproces,

                                                                 -- BUG16130:DRA:29/09/2010
                                                                 vcoderror, NULL);
      vtraza := 300;

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
         vnum_err := pac_gestion_procesos.f_set_carga_fichero(31, v_tfichero, 1, f_sysdate);

         IF vnum_err = 0 THEN
            vnum_err := pac_gestion_procesos.f_set_carga_fichero(31, v_tfichero, 2, f_sysdate);
         END IF;

         IF vnum_err = 0 THEN
            vnum_err := pac_gestion_procesos.f_set_carga_fichero(31, v_tfichero, 3, f_sysdate);
         END IF;

         IF vnum_err = 0 THEN
            vnum_err := pac_gestion_procesos.f_set_carga_fichero(43, v_tfichero, 2, f_sysdate);
         END IF;

         IF vnum_err = 0 THEN
            vnum_err := pac_gestion_procesos.f_set_carga_fichero(43, v_tfichero, 2, f_sysdate);
         END IF;

         IF vnum_err = 0 THEN
            vnum_err := pac_gestion_procesos.f_set_carga_fichero(43, v_tfichero, 3, f_sysdate);
         END IF;

         IF vnum_err = 0 THEN
            vnum_err := pac_gestion_procesos.f_set_carga_fichero(44, v_tfichero, 2, f_sysdate);
         END IF;

         IF vnum_err = 0 THEN
            vnum_err := pac_gestion_procesos.f_set_carga_fichero(44, v_tfichero, 2, f_sysdate);
         END IF;

         IF vnum_err = 0 THEN
            vnum_err := pac_gestion_procesos.f_set_carga_fichero(44, v_tfichero, 3, f_sysdate);
         END IF;

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
         pac_cargas_rga.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror, psproces,
                                      'Error:' || vnum_err || ' ' || vdeserror);
         COMMIT;
         RETURN 1;
      WHEN errorini THEN   --Error al insertar estados
         ROLLBACK;
         pac_cargas_rga.p_genera_logs(vobj, vtraza,
                                      'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                                      'Error:' || 'Insertando estados registros', psproces,
                                      f_axis_literales(108953, k_idiomaaaxis) || ':'
                                      || v_tfichero || ' : ' || 'errorini');
         COMMIT;
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         --KO si ha habido algun error en la cabecera
         pac_cargas_rga.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, SQLERRM, psproces,
                                      f_axis_literales(103187, k_idiomaaaxis) || ':'
                                      || v_tfichero || ' : ' || SQLERRM);
         vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, v_tfichero,
                                                                    vffini,
                                                                    --f_sysdate,  -- jlb CORREGIR!!
                                                                    NULL, 1, p_cproces,

                                                                    -- BUG16130:DRA:29/09/2010
                                                                    151541, SQLERRM);

         IF vnum_err <> 0 THEN
            pac_cargas_rga.p_genera_logs
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
                                                                                         procedimiento que traspasa de la tabla int_rga_ext a int_rga
          param in   out pdeserror   : mensaje de error
          param in psproces   : Número proceso
      *************************************************************************/
   PROCEDURE p_trasp_tabla(pdeserror OUT VARCHAR2, psproces IN NUMBER) IS
      num_err        NUMBER;
      v_pasexec      NUMBER := 1;
      vparam         VARCHAR2(1) := NULL;
      vobj           VARCHAR2(200) := 'pac_cargas_RGA.p_trasp_tabla';
      v_dummy        NUMBER;
      v_numerr       NUMBER := 0;
      errgrabarprov  EXCEPTION;
      e_object_error EXCEPTION;
      v_linea        NUMBER := 0;
      v_sproduc      seguros.sproduc%TYPE;
   BEGIN
      v_pasexec := 0;
      pdeserror := NULL;

      INSERT INTO int_rga
         (SELECT psproces sinterf, ROWNUM, empresa, producto, poliza_participe, nif, nombre,
                 apellidos, direccion, cp, poblacion, provincia,
                 TO_CHAR(fec_nac, 'DD/MM/RRRR'), caja_gestora, caja_cobradora,
                 oficina_gestora, oficina_cobradora, empleado, importe_emitidos_prod,
                 importe_anulados_prod, importe_emitidos_cart, importe_anulados_cart,
                 importe_emitidos_recur, importe_anulados_recur, num_rec_produccion_emitidos,
                 num_rec_produccion_anulados, num_rec_cartera_emitidos,
                 num_rec_cartera_anulados, num_rec_recurrentes_emitidos,
                 num_rec_recurrentes_anulados, forma_pago, tipo,
                 com_deveng_produccion_emision, com_deveng_produccion_anulaci,
                 com_deveng_cartera_emision, com_deveng_cartera_anulacion,
                 com_deveng_recur_emision, com_deveng_recur_anulacion, com_produccion_cobros,
                 com_produccion_devoluciones, com_cartera_cobros, com_cartera_devoluciones,
                 importe_descuento_om, TO_CHAR(fec_contratacion, 'DD/MM/RRRR'),
                 TO_CHAR(fec_efecto, 'DD/MM/RRRR'), TO_CHAR(fec_vencimiento, 'DD/MM/RRRR'),
                 TO_CHAR(fec_anulacion, 'DD/MM/RRRR'),
                 TO_CHAR(fec_inicio_periodo, 'DD/MM/RRRR'),
                 TO_CHAR(fec_fin_periodo, 'DD/MM/RRRR'), num_siniestros, importe_pagos,
                 prima_neta_anualizada, provision_matematica, num_partipaciones,
                 valor_participacion, comision_respu, cuenta_corriente, poliza_aseguradora,
                 cia_aseguradora, beneficiario, agru1, agru2, importe_prima_unica,
                 aport_promotor_ext, anul_aport_promotor_ext, traspasos_entrada,
                 traspasos_salida, traspasos_internos_ent, traspasos_internos_sal, inverco,
                 nif_tomador, nombre_tomador, apellidos_tomador, direccion_tomador,
                 cp_tomador, poblacion_tomador, provincia_tomador,
                 TO_CHAR(fec_nac_tomador, 'DD/MM/RRRR'), importe_valor_rescate, importe_pb,
                 importe_facturacion_acumulada, motivo_anulacion,
                 imp_presta_pensiones_capital, imp_presta_pens_rent_financie,
                 imp_presta_pens_a_vida, imp_presta_pens_de_vida,
                 imp_presta_pens_rent_asegurad, imp_presta_pens_retenciones,
                 imp_presta_vida_siniestros, imp_presta_vida_vencimientos,
                 imp_presta_vida_rescates, imp_presta_vida_rentas, imp_capital_final_vida,
                 capital_asegurado, num_siniestros_pendientes, num_siniestros_cerrados,
                 capital_2, capital_3, capital_4, capital_5, importe_calendario, NULL, NULL,
                 psproces proceso,
                                  -- Bug 14888. - JRH - 14/01/2011  - 0017159: CRT002 - Carga de productos de ahorro (CTASEGURO), pensiones, unit link de RGA
                                  imp_aport_extraord_neta, imp_fact_casada_neta,
                 traspaso_entrada_rga, traspaso_salida_rga
            -- Fi Bug 14888. - JRH - 14/01/2011
          FROM   int_rga_ext ire);

      v_pasexec := 1;
      COMMIT;

      DECLARE
         v_tipo         int_rga.tipo_oper%TYPE;

         CURSOR c1 IS
            SELECT ROWID, nlinea, poliza_participe, producto, fec_anulacion, empresa,
                                                                                     -- Bug 0016324. FAL. 18/10/2010.
                                                                                     proceso,

                   -- Fi bug 0016324
                   -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                   ncarga, tipo_oper
              -- Fi Bug 16324
            FROM   int_rga
             WHERE proceso = psproces;
      BEGIN
         FOR f1 IN c1 LOOP
            v_pasexec := 2;
            v_linea := f1.nlinea;
            v_sproduc := pac_cargas_rga.f_buscavalor('CRT_PRODRGA', f1.producto);

            IF v_sproduc IS NULL THEN
               p_tab_error(f_sysdate, f_user, vobj, v_pasexec,
                           'Póliza :' || f1.poliza_participe || ' producto : ' || f1.producto
                           || ' empresa : ' || f1.empresa,
                           SQLERRM);
               -- FAL. Se añade registrar antes la linea de cabecera.
               v_numerr :=
                  p_marcalinea
                     (f1.proceso, f1.nlinea, f1.tipo_oper, 1, 0, NULL,
                      -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      f1.poliza_participe,   -- Fi Bug 14888
                                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      f1.ncarga   -- Fi Bug 16324
                               );
               v_numerr := p_marcalineaerror(psproces, f1.nlinea, NULL, 1, 140720,
                                             'Error: 140720 - Póliza :' || f1.poliza_participe
                                             || ' producto : ' || f1.producto || ' empresa : '
                                             || f1.empresa || ' / ' || f1.producto || '-'
                                             || f1.empresa);
               -- v_tipo := 'ERR';
               v_tipo := 'ALTA';
            ELSIF v_sproduc = '-1' THEN   -- ese producto no se migra
               v_tipo := 'NOMIGRAR';
            ELSE
               SELECT COUNT('1')
                 INTO v_dummy
                 FROM seguros s
                WHERE s.cpolcia = f1.poliza_participe
                  AND s.sproduc = v_sproduc;

               IF v_dummy = 0 THEN
                  v_tipo := 'ALTA';
               ELSE
                  IF f1.fec_anulacion IS NOT NULL THEN
                     v_tipo := 'BAJA';
                  ELSE
                     v_tipo := 'MODI';
                  END IF;
               END IF;
            END IF;

            -- Fi bug 0016324

            -- Marcar como pendiente.
            IF v_tipo = 'ERR' THEN
               v_numerr :=
                  p_marcalinea
                     (psproces, f1.nlinea, v_tipo, 1, 0, NULL,
                      -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      f1.poliza_participe,   -- Fi Bug 14888
                                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      f1.ncarga   -- Fi Bug 16324
                               );

               IF v_numerr <> 0 THEN
                  RAISE errgrabarprov;
               END IF;
            ELSIF v_tipo = 'NOMIGRAR' THEN
               v_numerr :=
                  p_marcalinea
                     (psproces, f1.nlinea, v_tipo, 2, 0, NULL,
                      -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      f1.poliza_participe,   -- Fi Bug 14888
                                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      f1.ncarga   -- Fi Bug 16324
                               );

               IF v_numerr <> 0 THEN
                  RAISE errgrabarprov;
               END IF;

               v_numerr := p_marcalineaerror(psproces, f1.nlinea, NULL, 1, 9901330,
                                             'AVISO:  - Póliza :' || f1.poliza_participe
                                             || ' producto : ' || f1.producto || ' empresa : '
                                             || f1.empresa);

               IF v_numerr <> 0 THEN
                  RAISE errgrabarprov;
               END IF;
            ELSE
               v_numerr :=
                  p_marcalinea
                     (psproces, f1.nlinea, v_tipo, 3, 0, NULL,
                      -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
                      f1.poliza_participe,   -- Fi Bug 14888
                                             -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
                      f1.ncarga   -- Fi Bug 16324
                               );

               IF v_numerr <> 0 THEN
                  RAISE errgrabarprov;
               END IF;
            END IF;

            v_pasexec := 3;

            UPDATE int_rga
               SET tipo_oper = v_tipo,
                   proceso = f1.proceso
             WHERE ROWID = f1.ROWID;
         END LOOP;

         v_pasexec := 4;
      EXCEPTION
         WHEN errgrabarprov THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, 108953, vobj);
            pdeserror := f_axis_literales(108953, k_idiomaaaxis) || ':' || vobj;
            RAISE e_object_error;
         WHEN OTHERS THEN
            ROLLBACK;
            p_tab_error(f_sysdate, f_user, vobj, v_pasexec, SQLCODE, SQLERRM);
            pdeserror := f_axis_literales(105133, k_idiomaaaxis) || ':' || v_linea || '    '
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
         RAISE;
   END p_trasp_tabla;

   /**********************************************************************
                                                         Función que modifica la tabla ext para cargar un fichero
        param in p_nombre : Nombre fichero
        param in p_path : Nombre Path
        retorna 0 si ha ido bien, sino num_err.
   ***********************************************************************/
   FUNCTION f_modi_tabla_ext(p_nombre VARCHAR2)
      RETURN NUMBER IS
      v_tnomfich     VARCHAR2(100);
   BEGIN
      v_tnomfich := SUBSTR(p_nombre, 1, INSTR(p_nombre, '.') - 1);

      --Modificamos los logs
      EXECUTE IMMEDIATE 'alter table int_rga_ext ACCESS PARAMETERS (records delimited by newline
                   skip 1
                   logfile '
                        || CHR(39) || v_tnomfich || '.log' || CHR(39)
                        || '
                   badfile ' || CHR(39) || v_tnomfich || '.bad' || CHR(39)
                        || '
                   discardfile ' || CHR(39) || v_tnomfich || '.dis' || CHR(39)
                        || '
                   fields terminated by ''|''
                   MISSING FIELD VALUES ARE NULL
                   REJECT ROWS WITH ALL NULL FIELDS
                   ( EMPRESA,
                     PRODUCTO,
                     POLIZA_PARTICIPE,
                     NIF,
                     NOMBRE,
                     APELLIDOS,
                     DIRECCION,
                     CP   ,
                     POBLACION ,
                     PROVINCIA  ,
                     FEC_NAC  DATE MASK "dd-mm-yyyy",
                     CAJA_GESTORA ,
                     CAJA_COBRADORA,
                     OFICINA_GESTORA  ,
                     OFICINA_COBRADORA ,
                     EMPLEADO    ,
                     IMPORTE_EMITIDOS_PROD ,
                     IMPORTE_ANULADOS_PROD ,
                     IMPORTE_EMITIDOS_CART ,
                     IMPORTE_ANULADOS_CART ,
                     IMPORTE_EMITIDOS_RECUR ,
                     IMPORTE_ANULADOS_RECUR,
                     NUM_REC_PRODUCCION_EMITIDOS ,
                     NUM_REC_PRODUCCION_ANULADOS,
                     NUM_REC_CARTERA_EMITIDOS,
                     NUM_REC_CARTERA_ANULADOS ,
                     NUM_REC_RECURRENTES_EMITIDOS ,
                     NUM_REC_RECURRENTES_ANULADOS,
                     FORMA_PAGO ,
                     TIPO,
                     COM_DEVENG_PRODUCCION_EMISION ,
                     COM_DEVENG_PRODUCCION_ANULACI,
                     COM_DEVENG_CARTERA_EMISION ,
                     COM_DEVENG_CARTERA_ANULACION,
                     COM_DEVENG_RECUR_EMISION  ,
                     COM_DEVENG_RECUR_ANULACION  ,
                     COM_PRODUCCION_COBROS,
                     COM_PRODUCCION_DEVOLUCIONES  ,
                     COM_CARTERA_COBROS  ,
                     COM_CARTERA_DEVOLUCIONES ,
                     IMPORTE_DESCUENTO_OM,
                     FEC_CONTRATACION DATE MASK "dd-mm-yyyy",
                     FEC_EFECTO   DATE MASK "dd-mm-yyyy",
                     FEC_VENCIMIENTO  DATE MASK "dd-mm-yyyy",
                     FEC_ANULACION  DATE MASK "dd-mm-yyyy",
                     FEC_INICIO_PERIODO  DATE MASK "dd-mm-yyyy",
                     FEC_FIN_PERIODO  DATE MASK "dd-mm-yyyy",
                     NUM_SINIESTROS ,
                     IMPORTE_PAGOS ,
                     PRIMA_NETA_ANUALIZADA,
                     PROVISION_MATEMATICA ,
                     NUM_PARTIPACIONES ,
                     VALOR_PARTICIPACION ,
                     COMISION_RESPU ,
                     CUENTA_CORRIENTE ,
                     POLIZA_ASEGURADORA,
                     CIA_ASEGURADORA ,
                     BENEFICIARIO,
                     AGRU1 ,
                     AGRU2 ,
                     IMPORTE_PRIMA_UNICA  ,
                     APORT_PROMOTOR_EXT ,
                     ANUL_APORT_PROMOTOR_EXT  ,
                     TRASPASOS_ENTRADA  ,
                     TRASPASOS_SALIDA ,
                     TRASPASOS_INTERNOS_ENT  ,
                     TRASPASOS_INTERNOS_SAL ,
                     INVERCO  ,
                     NIF_TOMADOR   ,
                     NOMBRE_TOMADOR ,
                     APELLIDOS_TOMADOR  ,
                     DIRECCION_TOMADOR ,
                     CP_TOMADOR   ,
                     POBLACION_TOMADOR ,
                     PROVINCIA_TOMADOR ,
                     FEC_NAC_TOMADOR  DATE MASK "dd-mm-yyyy",
                     IMPORTE_VALOR_RESCATE  ,
                     IMPORTE_PB       ,
                     IMPORTE_FACTURACION_ACUMULADA ,
                     MOTIVO_ANULACION  ,
                     IMP_PRESTA_PENSIONES_CAPITAL ,
                     IMP_PRESTA_PENS_RENT_FINANCIE ,
                     IMP_PRESTA_PENS_A_VIDA ,
                     IMP_PRESTA_PENS_DE_VIDA ,
                     IMP_PRESTA_PENS_RENT_ASEGURAD ,
                     IMP_PRESTA_PENS_RETENCIONES,
                     IMP_PRESTA_VIDA_SINIESTROS ,
                     IMP_PRESTA_VIDA_VENCIMIENTOS ,
                     IMP_PRESTA_VIDA_RESCATES ,
                     IMP_PRESTA_VIDA_RENTAS  ,
                     IMP_CAPITAL_FINAL_VIDA ,
                     CAPITAL_ASEGURADO    ,
                     NUM_SINIESTROS_PENDIENTES  ,
                     NUM_SINIESTROS_CERRADOS  ,
                     CAPITAL_2,
                     CAPITAL_3,
                     CAPITAL_4,
                     CAPITAL_5 ,
                     IMPORTE_CALENDARIO,
                     IMP_APORT_EXTRAORD_NETA ,
                     IMP_FACT_CASADA_NETA ,
                     TRASPASO_ENTRADA_RGA,
                      TRASPASO_SALIDA_RGA

                  ))';

      --Cargamos el fichero
      EXECUTE IMMEDIATE 'ALTER TABLE int_rga_ext LOCATION (''' || p_nombre || ''')';

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_cargas_rga.f_crea_tabla_ext', 1,
                     'Error creando la tabla.', SQLERRM);
         RETURN 107914;
   END f_modi_tabla_ext;

   /*************************************************************************
                      procedimiento que ejecuta una carga (parte1 fichero)
          param in p_nombre   : Nombre fichero
          param out psproces   : Número proceso
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_ejecutar_carga_fichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.F_EJECUTAR_CARGA_FICHERO';
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
      vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_RGA', p_nombre, v_sproces);

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
      --Creamos la tabla int_rga_ext apartir del nombre de fichero enviado dinamicamente.
      vnum_err := f_modi_tabla_ext(p_nombre);

      IF vnum_err <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err,
                     'Error creando la tabla externa');
         vnum_err := f_proceslin(v_sproces,
                                 f_axis_literales(vnum_err, k_idiomaaaxis) || ':' || p_nombre
                                 || ' : ' || vnum_err,
                                 1, vnnumlin);
         RAISE errorini;   --Error que para ejecución
      END IF;

      p_trasp_tabla(vdeserror, v_sproces);
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
         pac_cargas_rga.p_genera_logs(vobj, vtraza, 'Error:' || vnum_err, vdeserror, psproces,
                                      'Error:' || vnum_err || ' ' || vdeserror);
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
          param in  out psproces   : Número proceso (informado para recargar proceso).
          retorna 0 si ha ido bien, 1 en casos contrario
      *************************************************************************/
   FUNCTION f_ejecutar_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.F_EJECUTAR_CARGA';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      vsalir         EXCEPTION;
      wlinerr        NUMBER := 0;   -- FAL - 07707/2011 - Bug 0019991
   BEGIN
      vtraza := 0;

      --  vnum_err := pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(k_empresaaxis,
      --                                                                     'USE1R_BBDD'));

      -- Bug 0016324. FAL. 18/10/2010
      SELECT NVL(cpara_error, 0), NVL(cbusca_host, 0)
        INTO k_para_carga, k_busca_host
        FROM cfg_files
       WHERE cempres = k_empresaaxis
         AND cproceso = p_cproces;

      -- Fi Bug 0016324
      IF psproces IS NULL THEN
         vnum_err := pac_cargas_rga.f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces,

                                                             -- BUG16130:DRA:15/10/2010
                                                             psproces);

         IF vnum_err <> 0 THEN
            RAISE vsalir;
         END IF;
      END IF;

      vtraza := 1;
      vnum_err := pac_cargas_rga.f_ejecutar_carga_proceso(psproces, p_cproces);

      -- BUG16130:DRA:15/10/2010
      IF vnum_err <> 0 THEN
         RAISE vsalir;
      END IF;

      -- FAL - 07/11/2011 - Bug 0019991: CRT002-Cargas Sicoef: marca el proceso como correcto cuando existen lineas erroneas
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

   -- Bug 0016324. FAL. 18/10/2010
   /*************************************************************************
             procedimiento que ejecuta una carga mediante un job
       param in  out psproces   : Número proceso (informado para recargar proceso).
       retorna 0 si ha ido bien, 1 en casos contrario
   *************************************************************************/
   FUNCTION f_ejecutar_carga_job(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER IS
      vmensaje       NUMBER;
      mensajes       t_iax_mensajes;
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.f_ejecutar_carga_job';
      vtraza         NUMBER := 0;
      v_tfichero     VARCHAR2(300) := p_path || '\' || p_nombre;
      vnum_err       NUMBER;
      vnnumlin       NUMBER;
   BEGIN
      IF psproces IS NULL THEN
         -- BUG 21546_108727- 01/03/2012 - JLTS - Se elimina la utilización de mensajes en pac_jobs.f_ejecuta_job
         vmensaje := pac_jobs.f_ejecuta_job(NULL,
                                            'pac_cargas_rga.p_ejecutar_carga(''' || p_nombre
                                            || ''',''' || p_path || ''',' || p_cproces || ');',
                                            NULL);

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
                                       f_axis_literales(180856, k_idiomaaaxis) || ':'
                                       || v_tfichero || ' : ' || vnum_err,
                                       1, vnnumlin);
               RETURN 1;
            END IF;

            --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, vmensaje);
            RETURN 1;
         END IF;

         RETURN 9901606;
      ELSE
         vnum_err := f_ejecutar_carga(p_nombre, p_path, p_cproces,   -- BUG16130:DRA:15/10/2010
                                      psproces);
         RETURN vnum_err;
      END IF;

      RETURN 0;
   END f_ejecutar_carga_job;

   -- Fi Bug 0016324
   PROCEDURE p_ejecutar_carga(p_nombre IN VARCHAR2, p_path IN VARCHAR2, p_cproces IN NUMBER) IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_RGA.P_EJECUTAR_CARGA';
      vtraza         NUMBER := 0;
      vnum_err       NUMBER;
      psproces       NUMBER;
   BEGIN
      vnum_err := pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(k_empresaaxis,
                                                                              'USER_BBDD'));
      vtraza := 0;

      -- Bug 0016324. FAL. 18/10/2010
      SELECT NVL(cpara_error, 0), NVL(cbusca_host, 0)
        INTO k_para_carga, k_busca_host
        FROM cfg_files
       WHERE cempres = k_empresaaxis
         AND cproceso = p_cproces;

      -- Fi Bug 0016324
      IF psproces IS NULL THEN
         vnum_err := pac_cargas_rga.f_ejecutar_carga_fichero(p_nombre, p_path, p_cproces,

                                                             -- BUG16130:DRA:15/10/2010
                                                             psproces);
      END IF;

      vtraza := 1;
      vnum_err := pac_cargas_rga.f_ejecutar_carga_proceso(psproces, p_cproces);
   -- BUG16130:DRA:15/10/2010
   END p_ejecutar_carga;
END pac_cargas_rga;

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_RGA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_RGA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_RGA" TO "PROGRAMADORESCSI";
