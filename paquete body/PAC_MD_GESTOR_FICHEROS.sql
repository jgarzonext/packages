--------------------------------------------------------
--  DDL for Package Body PAC_MD_GESTOR_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_GESTOR_FICHEROS" IS
   /****************************************************************************************
      FUNCTION f_generar_ficheros
      Aplica formateo a una columna de acuerdo a su tipo de dato y a su configuracion.
      param in ppempresa     : Empresa para la cual se genera el fichero del informe
               pptgestor     : Gestor o Informe del cual se va a generar el fichero
               pptformato    : Formato para el cual se va a generar el fichero
               pnanio        : Anio para el que se quiere generar el fichero
               ppnmes        : Mes de la informacion a generar en el fichero
               ppndia        : Dia de la informacion a generar en el fichero
      return                 : Numero que indica si el proceso fue exitoso o si se
                               presento algun error
   *******************************************************************************************/
   FUNCTION f_generar_ficheros(
      ppempresa IN NUMBER,
      pptgestor IN NUMBER,
      pptformato IN VARCHAR2,
      ppnanio IN NUMBER,
      ppnmes IN NUMBER,
      ppndia IN NUMBER,
      sproces OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER := 1;
      vobj           VARCHAR2(900) := 'PAC_MD_GESTOR_FICHEROS.f_generar_ficheros';
      vpar           VARCHAR2(900)
         := NULL || ' pcempres=' || ppempresa || ' pptgestor=' || pptgestor || ' pptformato='
            || pptformato || ' ppnanio=' || ppnanio || ' ppnmes=' || ppnmes || ' ppndia='
            || ppndia;
      vparam         VARCHAR2(900);
      vnumerr        NUMBER(8) := 0;
      v_sproceso     fic_procesos.sproces%TYPE;
      v_path_file    fic_procesos_detalle.tpathfi%TYPE;
      v_tuser        fic_procesos.cusuari%TYPE;
      v_ndia         fic_repositorio_formatos.tdiasem%TYPE;
      vidioma        NUMBER;
      vtexto         VARCHAR2(1000);
      v_tformato     VARCHAR2(30);
      v_fecha        DATE;
      v_mes          fic_repositorio_formatos.tperiod%TYPE;
      v_hay_datos    VARCHAR2(1);
      v_formatos     VARCHAR2(100);

      CURSOR cur_dat_formatos(
         p_gestor fic_repositorio_formatos.tgestor%TYPE,
         p_formato VARCHAR2,
         p_ejercicio fic_repositorio_formatos.nejerci%TYPE,
         p_periodo fic_repositorio_formatos.tperiod%TYPE,
         p_dia fic_repositorio_formatos.tdiasem%TYPE) IS
         SELECT 'x'
           FROM fic_repositorio_formatos
          WHERE tgestor = p_gestor
            --AND tformat IN (p_formato)
            --AND tformat IN (483)
            AND nejerci = p_ejercicio
            AND tperiod = TO_NUMBER(p_periodo)
            AND tdiasem = TO_NUMBER(p_dia)
            AND ROWNUM = 1;

      CURSOR cur_formatos IS
         SELECT tformat
           FROM fic_formatos
          WHERE tgestor = pptgestor;

      v_sentencia    VARCHAR2(1000);

      TYPE type_cur_consulta_csg IS REF CURSOR;

      cur_consulta   type_cur_consulta_csg;
      v_thay_datos   NUMBER;
   BEGIN
      vpas := 100;

      IF (ppempresa IS NULL) THEN
         vpas := 110;
         vparam := 'Parametro - Empresa';
         RAISE e_error_controlat;
      END IF;

      vpas := 120;

      IF (pptgestor IS NULL) THEN
         vpas := 130;
         vparam := 'Parametro - Informe';
         RAISE e_error_controlat;
      END IF;

      v_mes := ppnmes;

      IF (v_mes IS NULL) THEN
         v_mes := 0;
      END IF;

      v_ndia := ppndia;

      IF (v_ndia IS NULL) THEN
         v_ndia := 0;
      ELSE
         BEGIN
            vparam := 'Parametro - Fecha';   --select lpad('1',2,'0') from dual

            SELECT TO_DATE(LPAD(v_ndia, 2, '0') || LPAD(v_mes, 2, '0') || ppnanio, 'ddmmyyyy')
              INTO v_fecha
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS THEN
               RAISE e_error_controlat;
         END;
      END IF;

      IF (pptformato IS NULL) THEN
         FOR rg_formatos IN cur_formatos LOOP
            v_formatos := v_formatos || ',' || rg_formatos.tformat;
         END LOOP;

         IF (v_formatos = ',') THEN
            vparam := 'Parametro - Datos';
            RAISE e_error_controlat;
         ELSE
            v_formatos := SUBSTR(v_formatos, 2, LENGTH(v_formatos));
         END IF;
      ELSE
         v_sentencia :=
            'SELECT 0 dato
              FROM fic_repositorio_formatos
             WHERE tgestor = '
            || pptgestor || '
               AND tformat IN (' || pptformato
            || ')
               AND nejerci =' || ppnanio || ' AND tperiod = to_number(' || NVL(ppnmes, 0)
            || ')
                AND tdiasem = to_number(' || NVL(ppndia, 0)
            || ')
                AND ROWNUM = 1';

         --Comprobacion de parametros de entrada
         OPEN cur_consulta FOR v_sentencia;

         LOOP
            FETCH cur_consulta
             INTO v_thay_datos;

            EXIT WHEN cur_consulta%NOTFOUND;
         END LOOP;

         OPEN cur_dat_formatos(pptgestor, pptformato, ppnanio, v_mes, v_ndia);

         FETCH cur_dat_formatos
          INTO v_hay_datos;

         CLOSE cur_dat_formatos;

         IF (NVL(v_thay_datos, 1) = 1) THEN
            vparam := 'Parametro - Datos';
            RAISE e_error_controlat;
         ELSE
            v_formatos := pptformato;
         END IF;
      END IF;

      v_tuser := f_user;   --
      vnumerr := pac_fic_procesos.f_alta_procesoini(v_tuser, ppempresa, pptgestor, pptformato,
                                                    ppnanio, v_mes, v_ndia,
                                                    'GENERADOR_FICHEROS', vpar, v_sproceso);
      vnumerr := pac_jobs.f_ejecuta_job(NULL,
                                        'pac_fic_gestor_ficheros.p_proceso_job(' || ppempresa
                                        || ',' || pptgestor || ',' || chr(39) || v_formatos
                                        || chr(39) || ',' || ppnanio || ',' || v_mes || ','
                                        || v_ndia || ',' || chr(39) || v_tuser || chr(39) || ','
                                        || v_sproceso || ');',
                                        NULL);
      vidioma := pac_md_common.f_get_cxtidioma;
      vtexto := pac_iobj_mensajes.f_get_descmensaje(9001242, vidioma) || v_sproceso;   --'Proceso generado : '
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9001242, vtexto);

      IF vnumerr = 0 THEN
         vpas := 140;
         pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, 0,
                                              f_axis_literales(109904,
                                                               pac_iax_common.f_get_cxtidioma));
      ELSIF vnumerr <> 0 THEN
         vpas := 150;
         pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(vnumerr,
                                                               pac_iax_common.f_get_cxtidioma));
         RETURN vnumerr;
      END IF;

      vpas := 160;
      RETURN 0;
   EXCEPTION
      WHEN e_error_controlat THEN
         IF vparam = 'Parametro - Empresa' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(180500,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 180500;
         ELSIF vparam = 'Parametro - Informe' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9905869,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 9905869;
         ELSIF vparam = 'Parametro - Fecha' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9905943,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 9905943;
         ELSIF vparam = 'Parametro - Datos' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9905944,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 9905944;
         END IF;
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpas, vpar);
         RETURN vnumerr;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpas, vpar);
         RETURN vnumerr;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpas, vpar, NULL, SQLCODE,
                                           SQLERRM);
         RETURN vnumerr;
   END f_generar_ficheros;
END pac_md_gestor_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTOR_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTOR_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GESTOR_FICHEROS" TO "PROGRAMADORESCSI";
