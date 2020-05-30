--------------------------------------------------------
--  DDL for Package Body PAC_FIC_GESTOR_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FIC_GESTOR_FICHEROS" IS
   --
   vg_cempres     fic_gestores.cempres%TYPE;   --verificar si se esta usando
   vg_reg_original VARCHAR2(1000);   --registro sin formateo
   vg_counter     NUMBER(6) := 1;
   vg_counter_aux NUMBER(6) := 1;
   vg_txt_linea   VARCHAR2(4000);
   vg_secu_fichero NUMBER(6) := 0;   --secuencial de registros del fichero
   vg_secu_regs   NUMBER(6) := 1;   --secuencial de registros por tipo de registro
   vg_datos_cursor VARCHAR2(500);
   vg_separador   fic_gestores.tsepara%TYPE;

   TYPE type_arma_fichero IS RECORD(
      txt_linea      VARCHAR2(500),   --linea del archivo a generar
      reg_original   VARCHAR2(1000),   --variable para almacenar el registro sin formateos
      prg_excl_reg   VARCHAR2(100),   --programa que permite excluir un registro del plano
      prg_proces_post VARCHAR2(100)   --programa que se ejecuta cuando el campo se procesa posteriormente
   );

   TYPE tabla_type_arma_fichero IS TABLE OF type_arma_fichero
      INDEX BY BINARY_INTEGER;

   g_dinamic_fichero tabla_type_arma_fichero;

   /*************************************************************************
      FUNCTION f_aplica_formato
      Aplica formateo a una columna de acuerdo a su tipo de dato y a su configuracion.
      param in p_tcadena     : cadena con el dato de la columna a la que se aplica formato
               p_ttip_dato   : tipo de dato de la columna a la que se aplica formato
               p_nlongitud   : longitud de la columna
               p_tformato    : determina el formato a aplicar(Ej: DDMMYYYY para fechas)
               p_tcar_relleno: caracter con el cual se rellena la cadena hasta
                               completa la longitud definida.
               p_ttip_justifi: indica hacia en que extremo de la cadena se debe
                               aplicar el caracter de relleno.
      return                 : retorna la cadena con el formato aplicado y completada con el
                               caracter de relleno indicado, con la justificacion indicada
   *************************************************************************/
   FUNCTION f_aplica_formato(
      p_tcadena VARCHAR2,
      p_ttip_dato fic_col_ficheros.ttipdat%TYPE,
      p_nlongitud fic_col_ficheros.nlongit%TYPE,
      p_tformato fic_col_ficheros.tforcol%TYPE,
      p_tcar_relleno fic_col_ficheros.tcarrel%TYPE,
      p_ttip_justifi fic_col_ficheros.ttipjus%TYPE)
      RETURN VARCHAR2 IS
      v_tcadena      VARCHAR2(500);
   BEGIN
      v_tcadena := p_tcadena;

      IF (p_ttip_dato = 'N') THEN
         v_tcadena := LTRIM(v_tcadena);
      END IF;

      IF (p_tformato IS NOT NULL) THEN
         IF (p_tformato = 'MAYUS') THEN
            v_tcadena := UPPER(v_tcadena);
         ELSIF(p_tformato = 'MINUS') THEN
            v_tcadena := LOWER(v_tcadena);
         ELSE
            IF (p_ttip_dato = 'F') THEN
               v_tcadena := TO_CHAR(TO_DATE(v_tcadena), p_tformato);
            END IF;

            IF (p_ttip_dato = 'N') THEN
               v_tcadena := TO_CHAR(v_tcadena, p_tformato);
            END IF;
         END IF;
      END IF;

      IF (p_tcar_relleno IS NOT NULL) THEN
         IF (p_ttip_justifi = 'I') THEN
            v_tcadena := LPAD(NVL(v_tcadena, p_tcar_relleno), p_nlongitud, p_tcar_relleno);
         ELSIF(p_ttip_justifi = 'D') THEN
            v_tcadena := RPAD(NVL(v_tcadena, p_tcar_relleno), p_nlongitud, p_tcar_relleno);
         END IF;
      END IF;

      RETURN v_tcadena;
   END f_aplica_formato;

   /*************************************************************************
      PROCEDURE p_eval_excluidos
      Realiza el llamado a la funcion f_eval_excluidos para determinar si
      se incrementa o no el contador de registris
      param in p_tprograma     : programa que determina si se excluye o no el
                                 registro del fichero final.
               p_treg_original : cadena con el registro completo, sin haberle
                                 aplicado formateo
      return                   :
   *************************************************************************/
   PROCEDURE p_eval_excluidos(p_tprograma VARCHAR2, p_treg_original VARCHAR2) IS
      v_teval_excl   VARCHAR2(1) := 'N';
   BEGIN
      v_teval_excl := f_eval_excluidos(p_tprograma, p_treg_original);

      IF (v_teval_excl != 'S') THEN   --si no se excluye el registro se incrementa el contador
         vg_counter := vg_counter + 1;
      END IF;
   END p_eval_excluidos;

   /*************************************************************************
      FUNCTION f_eval_excluidos
      Evalua si de acuerdo a el resultado de un procedimiento se debe o no
      excluir ese registro en la escritura del fichero final.
      param in p_tprograma     : programa que determina si se excluye o no el
                                 registro del fichero final.
               p_treg_original : cadena con el registro completo, sin haberle
                                 aplicado formateo
      return                   : retorna la cadena con el formato aplicado y
                                 completada con el caracter de relleno indicado,
                                 con la justificacion indicada
   *************************************************************************/
   FUNCTION f_eval_excluidos(p_tprograma VARCHAR2, p_treg_original VARCHAR2)
      RETURN VARCHAR2 IS
      v_tresultado   VARCHAR2(1);
   BEGIN
      IF (p_tprograma IS NOT NULL) THEN
         EXECUTE IMMEDIATE ('begin ' || p_tprograma || '(' || ':1' || '); ' || 'end;')
                     USING IN p_treg_original;

         v_tresultado := NVL(pac_globales.f_obtiene_global('excl_reg'), 'N');
      ELSE
         v_tresultado := 'N';
      END IF;

      RETURN v_tresultado;
   END f_eval_excluidos;

   /*************************************************************************
      FUNCTION f_tokenizer
      Extrae el valor de una cadena, realizando la busqueda por una clave
      o subcaena y con base en unos separadores especificados
      param in p_tcadena     : Cadena con los datos del registro completo,
                               separando cada combinacion de clave valor
                               con un separador y la clave con su valor con
                               otro separador.
               p_tsubcadena  : clave que va a ser buscada dentro de la cadena
                               general para extraer el valor.
               p_tseparador  : Separador utilizado para identificar cada una de
                               las diferentes parejas de clave valor.
               p_tseparador2 : Separador utilizado para separar la clave del valor
                               como tal.
      return                 : retorna una cadena con el valor obtenido de acuerdo
                               a la clave o subcadena pasada.
   *************************************************************************/
   FUNCTION f_tokenizer(
      p_tcadena VARCHAR2,
      p_tsubcadena VARCHAR2,
      p_tseparador VARCHAR2,
      p_tseparador2 VARCHAR2)
      RETURN VARCHAR2 IS
      v_nposini      NUMBER(3) := 0;
      v_nposini2     NUMBER(3) := 0;
      v_ncant_caracteres NUMBER(3) := 0;
      v_tcadena_aux  VARCHAR2(500);
   BEGIN
      v_nposini := INSTR(UPPER(p_tcadena), UPPER(p_tsubcadena), 1);
      v_nposini2 := INSTR(UPPER(p_tcadena), UPPER(p_tseparador), v_nposini) - 1;

      IF (v_nposini2 <= 0) THEN
         v_nposini2 := LENGTH(p_tcadena);
      END IF;

      v_tcadena_aux := SUBSTR(p_tcadena, v_nposini, v_nposini2 - v_nposini + 1);
      v_ncant_caracteres := INSTR(v_tcadena_aux, p_tseparador2, 1);

      IF (v_ncant_caracteres <= 0) THEN
         v_ncant_caracteres := LENGTH(v_tcadena_aux);
      END IF;

      v_tcadena_aux := SUBSTR(v_tcadena_aux, v_ncant_caracteres + 1,
                              LENGTH(v_tcadena_aux) - v_ncant_caracteres);
      RETURN v_tcadena_aux;
   END f_tokenizer;

   /*************************************************************************
      PROCEDURE p_procesa_campos
      Permite procesar cada uno de los campos configurados en la estructura
      del fichero final.
      param in p_tgestor       : Gestor o estructura base que define el fichero
                                 de salida.
               p_ntip_registro : tipo de registro o seccion del fichero final
                                 que tiene su propia configuracion de columnas.
      return                   :
   *************************************************************************/
   PROCEDURE p_procesa_campos(
      p_tgestor fic_gestores.tgestor%TYPE,
      p_ntip_registro fic_tip_registros.ntipreg%TYPE) IS
      CURSOR cur_campos(
         p_tgest fic_gestores.tgestor%TYPE,
         p_ttip_reg fic_tip_registros.ntipreg%TYPE) IS
         SELECT   *
             FROM fic_col_ficheros
            WHERE tgestor = p_tgest
              AND ntipreg = p_ttip_reg
         ORDER BY ncolfic;

      v_tval_columna VARCHAR2(500);
      v_tval_campo   VARCHAR2(500);
      v_tval_tipo    VARCHAR2(500);
      v_tval_campo2  VARCHAR2(500);
      v_tseparador   fic_gestores.tsepara%TYPE := NULL;
   BEGIN
      vg_txt_linea := NULL;

      FOR vr_campos IN cur_campos(p_tgestor, p_ntip_registro) LOOP
         v_tval_campo := NULL;

         IF (vr_campos.tvaldef = 'PROCESA_POSTERIOR') THEN   --si la columna se va a procesar posteriormente
            v_tval_campo := 'PROCESA_POSTERIOR';
            vg_reg_original := vg_reg_original || v_tval_campo || ';';
            vg_txt_linea := vg_txt_linea || v_tval_campo;
            g_dinamic_fichero(vg_counter).prg_proces_post := vr_campos.tprodat;
         ELSE
            --si el valor de la columna se va a tomar de un campo de la consulta asociada al tipo de registro
            IF (vr_campos.tcolbas IS NOT NULL) THEN
               v_tval_campo := f_tokenizer(vg_datos_cursor, vr_campos.tcolbas, '|', ':');

               IF (NVL(vr_campos.tvarglo, 'N') = 'S') THEN
                  pac_globales.p_asigna_global('pre_' || vr_campos.tnombre, v_tval_campo);
               END IF;

               v_tval_tipo := f_tokenizer(vg_datos_cursor, 'TIPO', '|', ':');

               IF (NVL(vr_campos.tvarglo, 'N') = 'S') THEN
                  pac_globales.p_asigna_global('pre_' || 'TIPO', v_tval_tipo);
               END IF;
            END IF;

            --si el valor de la columna se va a obtener de un procedimiento
            IF (vr_campos.tprodat IS NOT NULL) THEN
               EXECUTE IMMEDIATE ('begin ' || vr_campos.tprodat || '(' || ':1' || '); '
                                  || 'end;')
                           USING OUT v_tval_campo2;

               IF (NVL(vr_campos.tvarglo, 'N') = 'S') THEN
                  IF (v_tval_campo IS NULL) THEN
                     pac_globales.p_asigna_global('pre_' || vr_campos.tnombre, v_tval_campo2);
                  ELSE
                     pac_globales.p_asigna_global('pos_' || vr_campos.tnombre, v_tval_campo2);
                  END IF;
               END IF;

               v_tval_campo := v_tval_campo2;
            END IF;

            --si es un valor fijo el que se va a asignar a la columna
            IF (vr_campos.tvaldef IS NOT NULL
                AND v_tval_campo IS NULL) THEN
               IF (vr_campos.tvaldef = 'SECUREGS') THEN
                  v_tval_campo := vg_secu_regs;
               ELSIF(vr_campos.tvaldef = 'SECUTOTA') THEN
                  v_tval_campo := vg_secu_fichero;
               ELSIF(UPPER(vr_campos.tvaldef) = 'SYS' || 'DATE') THEN
                  v_tval_campo := TO_CHAR(f_sysdate);
               ELSE
                  v_tval_campo := vr_campos.tvaldef;
               END IF;

               IF (NVL(vr_campos.tvarglo, 'N') = 'S') THEN
                  pac_globales.p_asigna_global('pre_' || vr_campos.tnombre, v_tval_campo);
               END IF;
            END IF;

            --ejecuta el programa de validación que se haya especificado.
            IF (vr_campos.tproval IS NOT NULL) THEN
               EXECUTE IMMEDIATE ('begin ' || vr_campos.tproval || '(' || ':1' || '); '
                                  || 'end;')
                           USING IN v_tval_campo;
            END IF;

            vg_reg_original := vg_reg_original || v_tval_campo || ';';

            IF (NVL(pac_globales.f_obtiene_global('excluye_formato_columna'), 'S') = 'S') THEN
               vg_txt_linea := vg_txt_linea || v_tseparador
                               || f_aplica_formato(v_tval_campo, vr_campos.ttipdat,
                                                   vr_campos.nlongit, vr_campos.tforcol,
                                                   vr_campos.tcarrel, vr_campos.ttipjus);
               pac_globales.p_asigna_global('excluye_formato_columna', NULL);
            ELSE
               vg_txt_linea := vg_txt_linea || v_tseparador || v_tval_campo;
            END IF;

            IF (v_tseparador IS NULL) THEN
               v_tseparador := vg_separador;
            END IF;
         END IF;
      END LOOP;
   END p_procesa_campos;

   /*************************************************************************
      PROCEDURE p_procesa_tip_registros
      Permite procesar cada tipo de registro o seccion del fichero con el
      proposito de obtener las columnas de ese tipo de registro y de acuerdo
      a la configuracion de cada una de ellas procesarlas.
      param in p_vr_registros : registro completo de la tabla fic_tip_registros
      return                   :
   *************************************************************************/
   PROCEDURE p_procesa_tip_registros(p_vr_registros fic_tip_registros%ROWTYPE) IS
      --cursor para obtener los tipos de registros hijos que seran llamados recursivamente
      CURSOR cur_tr_hijos(
         p_tgestor fic_gestores.tgestor%TYPE,
         p_ttip_registro fic_tip_registros.ntipreg%TYPE) IS
         SELECT *
           FROM fic_tip_registros
          WHERE tgestor = p_tgestor
            AND ntregpa = p_ttip_registro;

      TYPE type_cur_consulta_csg IS REF CURSOR;

      cur_consulta   type_cur_consulta_csg;
      v_tsentencia   VARCHAR2(20000);
      v_nsecu_regss  NUMBER(6) := 1;
      v_nnum_var     NUMBER(3);
      v_contador     NUMBER(3);
      v_setencia_aux VARCHAR2(20000);
      v_prueba       VARCHAR2(100);
      v_prueba2      VARCHAR2(100);
      v_variable     VARCHAR2(100);
      v_pos1         NUMBER(6);
      v_pos2         NUMBER(6);
   BEGIN
      vg_txt_linea := NULL;
      vg_reg_original := NULL;
      v_nsecu_regss := 1;

      IF (p_vr_registros.tquery IS NULL) THEN   --si es un solo registro
         vg_secu_fichero := vg_secu_fichero + 1;
         vg_secu_regs := vg_secu_regs + 1;
         vg_secu_regs := v_nsecu_regss;
         p_procesa_campos(p_vr_registros.tgestor, p_vr_registros.ntipreg);
         g_dinamic_fichero(vg_counter).txt_linea := vg_txt_linea;
         g_dinamic_fichero(vg_counter).reg_original := vg_reg_original;
         g_dinamic_fichero(vg_counter).prg_excl_reg := p_vr_registros.tprexre;
         p_eval_excluidos(g_dinamic_fichero(vg_counter).prg_excl_reg,
                          RTRIM(g_dinamic_fichero(vg_counter).reg_original, ';'));
      ELSE   --si son varios registros con base en una consulta
         v_tsentencia := p_vr_registros.tquery;
         v_setencia_aux := v_tsentencia;
         v_nnum_var := LENGTH(v_tsentencia) - LENGTH(REPLACE(v_tsentencia, '['));

         FOR v_contador IN 1 .. v_nnum_var LOOP
            v_pos1 := INSTR(v_setencia_aux, '[');
            v_pos2 := INSTR(v_setencia_aux, ']');
            v_variable := SUBSTR(v_setencia_aux, v_pos1 + 1, v_pos2 - v_pos1 - 1);
            v_tsentencia := REPLACE(v_tsentencia, '[' || v_variable || ']',
                                    pac_globales.f_obtiene_global(v_variable));
            v_setencia_aux := v_tsentencia;
         END LOOP;

         OPEN cur_consulta FOR v_tsentencia;

         LOOP
            vg_txt_linea := NULL;
            vg_reg_original := NULL;

            FETCH cur_consulta
             INTO vg_datos_cursor;

            EXIT WHEN cur_consulta%NOTFOUND;

            IF (p_vr_registros.tocultr = 'N') THEN   --si no es oculto, no se procesan ni escriben sus campos
               vg_secu_regs := vg_secu_regs + 1;
               vg_secu_fichero := vg_secu_fichero + 1;
               vg_secu_regs := v_nsecu_regss;
               p_procesa_campos(p_vr_registros.tgestor, p_vr_registros.ntipreg);
               g_dinamic_fichero(vg_counter).txt_linea := vg_txt_linea;
               g_dinamic_fichero(vg_counter).reg_original := vg_reg_original;
               g_dinamic_fichero(vg_counter).prg_excl_reg := p_vr_registros.tprexre;
               p_eval_excluidos(g_dinamic_fichero(vg_counter).prg_excl_reg,
                                RTRIM(g_dinamic_fichero(vg_counter).reg_original, ';'));
            ELSE   --si es oculto solo procesa el campo, pero no lo escribe en el archivo
               vg_secu_regs := v_nsecu_regss;
               p_procesa_campos(p_vr_registros.tgestor, p_vr_registros.ntipreg);
            END IF;

            FOR vr_tip_reg_hijos IN cur_tr_hijos(p_vr_registros.tgestor,
                                                 p_vr_registros.ntipreg) LOOP   --llamado recursivo a los tipos de registro hijos.
               p_procesa_tip_registros(vr_tip_reg_hijos);
            END LOOP;
         END LOOP;

         CLOSE cur_consulta;
      END IF;
   END p_procesa_tip_registros;

   /*************************************************************************
      PROCEDURE p_crea_registros
      Permite realizar el llamado a cada uno de los tipos de registro.
      param in p_tgestor : gestor o estructura base que define el fichero de
                           salida y del cual se obtendran los tipos de registros
                           que deberan ser procesados.
      return             :
   *************************************************************************/
   PROCEDURE p_crea_registros(p_tgestor fic_gestores.tgestor%TYPE) IS
      CURSOR cur_tip_registros(p_tgest fic_gestores.tgestor%TYPE) IS
         SELECT   *
             FROM fic_tip_registros
            WHERE tgestor = p_tgest
              AND ntregpa IS NULL
         ORDER BY nseceje;
   BEGIN
      FOR vr_registros IN cur_tip_registros(p_tgestor) LOOP
         p_procesa_tip_registros(vr_registros);
      END LOOP;
   END p_crea_registros;

   /*************************************************************************
      FUNCTION f_escribe_fichero
      Permite realizar la escritura en el fichero de las lineas generadas para
      cada tipo de registro.
      param in :
      return   :Devuelve el path y nombre del fichero generado
   *************************************************************************/
   FUNCTION f_escribe_fichero
      RETURN VARCHAR2 IS
      v_tlinea       VARCHAR2(500);
      v_teval_excl   VARCHAR2(1);
      v_archivo      UTL_FILE.file_type;
      --
      v_path_file    VARCHAR2(500);
      v_nomb_file    VARCHAR2(200);
   BEGIN
      v_nomb_file := 'INF' || pac_globales.f_obtiene_global('vg_gestor') || '_'
                     || TO_CHAR(f_sysdate, 'YYYYMMDDHH24MI');
      v_archivo := UTL_FILE.fopen(pac_parametros.f_parinstalacion_t('INFORMES'), v_nomb_file,
                                  'w');

      --
      FOR i IN vg_counter_aux .. g_dinamic_fichero.COUNT LOOP
         IF (g_dinamic_fichero(vg_counter_aux).prg_excl_reg IS NULL) THEN
            IF (INSTR(g_dinamic_fichero(vg_counter_aux).txt_linea, 'PROCESA_POSTERIOR') > 0) THEN
               EXECUTE IMMEDIATE ('begin ' || g_dinamic_fichero(vg_counter_aux).prg_proces_post
                                  || '(' || ':1' || '); ' || 'end;')
                           USING OUT v_tlinea;

               v_tlinea := REPLACE(g_dinamic_fichero(vg_counter_aux).txt_linea,
                                   'PROCESA_POSTERIOR', v_tlinea);
            ELSE
               v_tlinea := g_dinamic_fichero(vg_counter_aux).txt_linea;
            END IF;

            UTL_FILE.put_line(v_archivo, v_tlinea);
         ELSE
            --si se va a excluir el registro, se evalua la condicion para ver si se excluye o no
            v_teval_excl :=
               f_eval_excluidos(g_dinamic_fichero(vg_counter_aux).prg_excl_reg,
                                RTRIM(g_dinamic_fichero(vg_counter_aux).reg_original, ';'));

            IF (NVL(v_teval_excl, 'N')) = 'N' THEN
               IF (INSTR(g_dinamic_fichero(vg_counter_aux).txt_linea, 'PROCESA_POSTERIOR') > 0) THEN
                  EXECUTE IMMEDIATE ('begin '
                                     || g_dinamic_fichero(vg_counter_aux).prg_proces_post
                                     || '(' || ':1' || '); ' || 'end;')
                              USING OUT v_tlinea;

                  v_tlinea := REPLACE(g_dinamic_fichero(vg_counter_aux).txt_linea,
                                      'PROCESA_POSTERIOR', v_tlinea);
               ELSE
                  v_tlinea := g_dinamic_fichero(vg_counter_aux).txt_linea;
               END IF;

               UTL_FILE.put_line(v_archivo, v_tlinea);
            END IF;
         END IF;

         vg_counter_aux := vg_counter_aux + 1;
      END LOOP;

      UTL_FILE.fclose(v_archivo);
      v_path_file := pac_parametros.f_parinstalacion_t('INFORMES_C');
      RETURN v_path_file || '/' || v_nomb_file;
   END f_escribe_fichero;

   /*************************************************************************
      FUNCTION f_proceso
      Funcion principal desde donde se lleva el control de flujo del
      proceso.
      param in p_nempresa  : empresa para la cual se va a generar el fichero.
               p_tgestor   : gestor o estructura base que define el fichero
                             final de salida.
               p_tformatos : formato o formatos que pertenezcan al gestor y
                             de los cuales se incluira su informacion en el
                             fichero final que se genere.
      return   :   Devuelve el nombre completo del fichero generado
   *************************************************************************/
   FUNCTION f_proceso(
      p_nempresa fic_gestores.cempres%TYPE,
      p_tgestor fic_gestores.tgestor%TYPE,
      p_tformatos VARCHAR2,
      p_nanio NUMBER,
      p_nmes NUMBER,
      p_nsem_dia NUMBER)
      RETURN VARCHAR2 IS
      CURSOR cur_separador(
         p_nempres fic_gestores.cempres%TYPE,
         p_tgest fic_gestores.tgestor%TYPE) IS
         SELECT ttipfic, tsepara
           FROM fic_gestores
          WHERE cempres = p_nempres
            AND tgestor = p_tgest;

      v_tseparador   fic_gestores.tsepara%TYPE;
      v_ttip_fichero fic_gestores.ttipfic%TYPE;
      v_sproceso     fic_procesos.sproces%TYPE;
      v_tpathfile    VARCHAR2(500);
   BEGIN
      --Asigna variables globales en memoria
      pac_globales.p_asigna_global('empresa', p_nempresa);
      pac_globales.p_asigna_global('gestor', p_tgestor);
      pac_globales.p_asigna_global('formato', p_tformatos);
      pac_globales.p_asigna_global('anio', p_nanio);
      pac_globales.p_asigna_global('mes', p_nmes);
      pac_globales.p_asigna_global('dia', p_nsem_dia);

      OPEN cur_separador(p_nempresa, p_tgestor);

      FETCH cur_separador
       INTO v_ttip_fichero, v_tseparador;

      CLOSE cur_separador;

      vg_separador := v_tseparador;
      g_dinamic_fichero.DELETE;
      p_crea_registros(p_tgestor);
      v_tpathfile := f_escribe_fichero;
      RETURN v_tpathfile;
   END f_proceso;

   /*************************************************************************
      PROCEDURE p_proceso
      Procedimiento para ser llamado desde la capa media, que es ejecutado
      por el job
      proceso.
      param in p_nempresa  : empresa para la cual se va a generar el fichero.
               p_tgestor   : gestor o estructura base que define el fichero
                             final de salida.
               p_tformatos : formato o formatos que pertenezcan al gestor y
                             de los cuales se incluira su informacion en el
                             fichero final que se genere.
      return   :
   *************************************************************************/
   PROCEDURE p_proceso_job(
      p_nempresa fic_gestores.cempres%TYPE,
      p_tgestor fic_gestores.tgestor%TYPE,
      p_tformatos VARCHAR2,
      p_nanio NUMBER,
      p_nmes NUMBER,
      p_nsem_dia NUMBER,
      p_tuser fic_procesos.cusuari%TYPE,
      p_proceso fic_procesos.sproces%TYPE) IS
      vnumerr        NUMBER;
      v_sproceso     NUMBER;
      v_prolin       NUMBER;
      v_path_file    fic_procesos_detalle.tpathfi%TYPE;
   BEGIN
      v_path_file := pac_fic_gestor_ficheros.f_proceso(p_nempresa, p_tgestor, p_tformatos,
                                                       p_nanio, p_nmes, p_nsem_dia);
      vnumerr := pac_fic_procesos.f_alta_proceso_detalle(p_proceso, 1, v_path_file, v_prolin,
                                                         4);
      vnumerr := pac_fic_procesos.f_update_procesofin(p_proceso, vnumerr);
   END p_proceso_job;
END pac_fic_gestor_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_FIC_GESTOR_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FIC_GESTOR_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FIC_GESTOR_FICHEROS" TO "PROGRAMADORESCSI";
