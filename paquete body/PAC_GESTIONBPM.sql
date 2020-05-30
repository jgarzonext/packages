--------------------------------------------------------
--  DDL for Package Body PAC_GESTIONBPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_GESTIONBPM" IS
/******************************************************************************
   NOMBRE:       PAC_GESTIONBPM
   PROPÓSITO: Funciones para integracion de BPM con AXIS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/11/2012   FPG              1. Creación del package.
   2.0        23/09/2013   JDS              2. 0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
   3.0        30/09/2013   JDS              3. Desarrollo PL interfases 2-Notificar movimiento carátula y 9-Notificar riesgos asegurables
   4.0        26/11/2013   FPG              4. 0028129: LCOL899-Desarrollo interfases BPM-iAXIS .
                                               a. En la interfase 'Notificar riesgos asegurables' el BPM enviará
                                                 el código de suplemento de iAxis en vez de INCLUSION / MODIFICACION / EXCLUSION
                                               b. Modificar el tipo del campo idgestordocbpm a VARCHAR2
   5.0        02/12/2013   FPG              5. 0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
                                             Aumentar la longitud de la variable vparam a 1000

******************************************************************************/
   e_param_error  EXCEPTION;

    /*********************************************************************************************************************
   * Funcion f_set_mov_colectivo
   * Esta función se utiliza para grabar el caso en la tabla CASOS_BPM con los datos que llegan en la interfase 2 - Notificar movimiento carátula
   *
   * Parametros:    pcempres_in NUMBER,
                    pidcasobpm_in NUMBER,
                    pcramo_in NUMBER,
                    psproduc_in NUMBER,
                    pnpoliza_in NUMBER,
                    pcmotmov_in NUMBER,
                    cusuasignado_in VARCHAR2,
                    pctipide_in NUMBER,
                    pnnumide_in VARCHAR2,
                    pnombre_in VARCHAR2
   * Return: 0 si no hay error o el código de error
   **********************************************************************************************************************/
   FUNCTION f_set_mov_colectivo(
      pcempres_in NUMBER,
      pidcasobpm_in NUMBER,
      pcramo_in NUMBER,
      psproduc_in NUMBER,
      pnpoliza_in NUMBER,
      pcmotmov_in NUMBER,
      pcusuasignado_in VARCHAR2,
      pctipide_in NUMBER,
      pnnumide_in VARCHAR2,
      pnombre_in VARCHAR2,
      pnnumcaso_out OUT NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(100) := 'PAC_GESTIONBPM.f_set_mov_colectivo';
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(1000)
         := 'Parametros: pcempres_in= ' || pcempres_in || ' pidcasobpm_in= ' || pidcasobpm_in
            || ' pcramo_in= ' || pcramo_in || ' psproduc_in= ' || psproduc_in
            || ' pnpoliza_in= ' || pnpoliza_in || ' pcmotmov_in= ' || pcmotmov_in
            || ' pcusuasignado_in= ' || pcusuasignado_in || ' pctipide_in= ' || pctipide_in
            || ' pnnumide_in= ' || pnnumide_in || ' pnombre_in= ' || pnombre_in;
      vctipmov_bpm   NUMBER;
      vcmovseg       NUMBER;
   BEGIN
      SELECT seq_casos_bpm_nnumcaso.NEXTVAL
        INTO pnnumcaso_out
        FROM DUAL;

      v_pasexec := 10;

      --Calcular el campo CTIPMOV_BPM de la siguiente forma
      --  Si pcmotmov_in = 996 ó 997 entonces vctipmov_bpm = 2 - Novedades de asegurados (Altas/Bajas/Modif)
      --  Si pcmotmov = 100 entonces CTIPMOV_BPM = 1 - Creación certificado 0
      --  Si no, obtener el campo cmovseg de la tabla CODIMOTMOV
      --  Si cmovseg = 4 entonces CTIPMOV_BPM = 5 - Rehabilitación certificado 0
      --  Si cmovseg = 3 entonces CTIPMOV_BPM = 4 - Anulación certificado 0
      --  En caso contrario CTIPMOV_BPM  = 3 - Suplemento certificado 0
      IF (pcmotmov_in = 100) THEN
         v_pasexec := 11;
         vctipmov_bpm := 1;
      ELSIF(pcmotmov_in = 996
            OR pcmotmov_in = 997) THEN
         v_pasexec := 12;
         vctipmov_bpm := 2;   -- Novedades de asegurados (Altas/Bajas/Modif))
      ELSE
         v_pasexec := 13;

         BEGIN
            SELECT cmovseg
              INTO vcmovseg
              FROM codimotmov
             WHERE cmotmov = pcmotmov_in;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcmovseg := 0;
         END;

         IF vcmovseg = 4 THEN
            v_pasexec := 14;
            vctipmov_bpm := 5;
         ELSIF vcmovseg = 3 THEN
            v_pasexec := 15;
            vctipmov_bpm := 4;
         ELSE
            v_pasexec := 16;
            vctipmov_bpm := 3;
         END IF;
      END IF;

      --   Hacer el insert en la tabla CASOS_BPM con los siguientes datos:
      --   CEMPRES = pcempres_in
      --   NNUMCASO = el obtenido de la secuencia SEQ_CASOS_BPM_NNUMCASO
      --   CUSUASIGNADO = pcusuasignado _in
      --   CTIPOPROCESO = 1 - Emisión de pólizas
      --   CESTADO = 1 - Caso recibido en iAXIS
      --   CESTADOENVIO = 0 - No enviado
      --  FALTA : se informa automáticamente con el trigger
      --   FBAJA = nulo
      --   CUSUALT : se informa automáticamente con el trigger
      --   FMODIFI : se informa automáticamente con el trigger
      --   CUSUMOD : se informa automáticamente con el trigger
      --   SPRODUC = psproduc_in
      --   CMOTMOV= pcmotmov_in
      --   CTIPIDE = pctipide_in
      --   NNUMIDE = pnnumide_in
      --   TNOMCOM = pnombre_in
      --   NPOLIZA = pnpoliza_in
      --   NCERTIF = nulo
      --   NMOVIMI = nulo
      --   NNUMCASOP = nulo
      --   NCASO_BPM = pidcasobpm_in
      --   NSOLICI_BPM = 0
      --   CTIPMOV_BPM = el campo calculado antes
      --   CAPROBADA_BPM = 1 - Aprobada
      v_pasexec := 20;
      v_param := v_param || ', pnnumcaso_out: ' || pnnumcaso_out;

      INSERT INTO casos_bpm
                  (cempres, nnumcaso, cusuasignado, ctipoproceso, cestado, cestadoenvio,
                   fbaja, sproduc, cmotmov, ctipide, nnumide, tnomcom,
                   npoliza, ncertif, nmovimi, nnumcasop, ncaso_bpm, nsolici_bpm, ctipmov_bpm,
                   caprobada_bpm)
           VALUES (pcempres_in, pnnumcaso_out, pcusuasignado_in, 1, 1, 0,
                   NULL, psproduc_in, pcmotmov_in, pctipide_in, pnnumide_in, pnombre_in,
                   pnpoliza_in, 0, NULL, NULL, pidcasobpm_in, 0, vctipmov_bpm,
                   1);

      v_pasexec := 30;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_set_mov_colectivo;

   /*********************************************************************************************************************
    * Funcion f_set_docreq
    * Esta función se utiliza para grabar los datos de los documentos requeridos que llegan en la interfase
    * "2 - Notificar movimiento carátula" o en la interfase "9 - Notificar riesgos asegurables".
    *
    Bug 28129 - FPG - 26-11-2013 Modificar el tipo del campo idgestordocbpm de NUMBER a VARCHAR2
    * Parametros:    pcempres_in NUMBER
                   pnnumcaso_in NUMBER
                    pcdocume_in NUMBER
                    --pidgestordocbpm_in NUMBER
                    pidgestordocbpm_in VARCHAR2

    * Return: 0 si no hay error o el código de error
    **********************************************************************************************************************/
   FUNCTION f_set_docreq(
      pcempres_in IN NUMBER,
      pnnumcaso_in IN NUMBER,
      pcdocume_in IN NUMBER,
      pidgestordocbpm_in IN VARCHAR2)
      RETURN NUMBER IS
      v_object       VARCHAR2(100) := 'PAC_GESTIONBPM.f_set_docreq';
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(1000)
         := 'Parametros: pcempres_in= ' || pcempres_in || ' pnnumcaso_in= ' || pnnumcaso_in
            || ' pcdocume_in= ' || pcdocume_in || ' pcdocume_in= ' || pcdocume_in
            || ' pidgestordocbpm_in= ' || pidgestordocbpm_in;
   -- Hacer el insert en la tabla CASOS_BPM_DOC con los siguientes datos:
   --CEMPRES = pcempres_in
   --NNUMCASO = pnnumcaso_in
   --IDGESTORDOCBPM = pidgestordocbpm_in
   --CDOCUME = pcdocume_in
   --CESTADODOC  = 1 - Pendiente subir a Gedox
   --IDDOC = nulo
   --Estos campos es necesario informarlos
   --FALTA : se informa automáticamente con el trigger
   --FBAJA
   --CUSUALT : se informa automáticamente con el trigger
   --FMODIFI : se informa automáticamente con el trigger
   --CUSUMOD : se informa automáticamente con el trigger
   BEGIN
      INSERT INTO casos_bpm_doc
                  (cempres, nnumcaso, idgestordocbpm, cdocume, cestadodoc, iddoc, fbaja)
           VALUES (pcempres_in, pnnumcaso_in, pidgestordocbpm_in, pcdocume_in, 1, NULL, NULL);

      v_pasexec := 10;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_set_docreq;

   /*********************************************************************************************************************
    * Funcion f_valida_caso_BPM
    * Esta función valida si el nº de caso BPM recibido existe en iAxis en la tabla CASOS_BPM y si está en un estado que permite modificaciones
    *
    * Parametros:  pcempres_in NUMBER: Empresa
                   pncaso_bpm_in NUMBER: número del caso en el BPM
                   pnsolici_bpm_in NUMBER: número de la solicitud en el BPM
                   pnnumcaso_in NUMBER: número del caso interno de iAxis
                   pnpoliza_in NUMBER: número de póliza
                   psproduc_in NUMBER: código del producto

      Parámetros de salida:
                   pncaso_bpm_out NUMBER: número del caso en el BPM
                   pnsolici_bpm_out NUMBER: número de la solicitud en el BPM
                   pnnumcaso_out NUMBER: número del caso interno de iAxis

    * Return: 0 si no hay error o el código de error
    **********************************************************************************************************************/
   FUNCTION f_valida_caso_bpm(
      pcempres_in NUMBER,
      pncaso_bpm_in NUMBER,
      pnsolici_bpm_in NUMBER,
      pnnumcaso_in NUMBER,
      pnpoliza_in NUMBER,
      psproduc_in NUMBER,
      pncaso_bpm_out OUT NUMBER,
      pnsolici_bpm_out OUT NUMBER,
      pnnumcaso_out OUT NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(100) := 'PAC_GESTIONBPM.f_valida_caso_BPM';
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(1000)
         := 'Parametros: pcempres_in= ' || pcempres_in || ' pncaso_bpm_in= ' || pncaso_bpm_in
            || ' pnsolici_bpm_in= ' || pnsolici_bpm_in || ' pnnumcaso_in= ' || pnnumcaso_in
            || ' pnpoliza_in= ' || pnpoliza_in || ' psproduc_in= ' || psproduc_in;
      vaux           NUMBER;
      vcestado       NUMBER;
      vnpoliza       NUMBER;
      vnnumcaso      NUMBER;
      vncaso_bpm     NUMBER;
      vnsolici_bpm   NUMBER;
      vsproduc       NUMBER;
   BEGIN
      v_pasexec := 10;

      --Leer la tabla CASOS_BPM según los parámetros informados
      IF (NVL(pnpoliza_in, 0) = 0
          OR NVL(psproduc_in, 0) = 0) THEN
         RAISE e_param_error;   --Objecto invocado con parámetros erroneos
      ELSE
         v_pasexec := 11;

         SELECT COUNT(1)
           INTO vaux
           FROM seguros
          WHERE npoliza = pnpoliza_in
            AND ncertif = 0;

         IF vaux = 0 THEN
            RETURN 9906020;   -- Póliza informada no existe en iAxis'
         END IF;

         v_pasexec := 12;

         SELECT COUNT(1)
           INTO vaux
           FROM seguros
          WHERE npoliza = pnpoliza_in
            AND sproduc = psproduc_in;

         IF vaux = 0 THEN
            RETURN 9906146;   -- La póliza no es del producto informado
         END IF;
      END IF;

      --Leer la tabla CASOS_BPM según los parámetros informados
      BEGIN
         IF NVL(pnnumcaso_in, 0) = 0 THEN
            IF NVL(pncaso_bpm_in, 0) = 0 THEN
               v_pasexec := 11;
               RAISE e_param_error;   --Objecto invocado con parámetros erroneos
            ELSE
               v_pasexec := 12;

               SELECT   COUNT(*), cestado, npoliza, nnumcaso, ncaso_bpm, nsolici_bpm,
                        sproduc
                   INTO vaux, vcestado, vnpoliza, vnnumcaso, vncaso_bpm, vnsolici_bpm,
                        vsproduc
                   FROM casos_bpm
                  WHERE cempres = pcempres_in
                    AND ncaso_bpm = pncaso_bpm_in
                    AND nsolici_bpm = NVL(pnsolici_bpm_in, 0)
               GROUP BY cestado, npoliza, nnumcaso, ncaso_bpm, nsolici_bpm, sproduc;
            END IF;
         ELSE
            v_pasexec := 15;

            SELECT   COUNT(*), cestado, npoliza, nnumcaso, ncaso_bpm, nsolici_bpm, sproduc
                INTO vaux, vcestado, vnpoliza, vnnumcaso, vncaso_bpm, vnsolici_bpm, vsproduc
                FROM casos_bpm
               WHERE cempres = pcempres_in
                 AND nnumcaso = pnnumcaso_in
            GROUP BY cestado, npoliza, nnumcaso, ncaso_bpm, nsolici_bpm, sproduc;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_pasexec := 16;
            vaux := 0;
      END;

      v_pasexec := 20;

      IF vaux = 0 THEN
         v_pasexec := 21;
         RETURN 9904622;   --Número de caso inexistente
      END IF;

      v_pasexec := 30;
      --IF vcestado = 3 THEN
       --  v_pasexec := 31;
       --  RETURN 9906031;   --Caso emitido en iAxis, no se admiten modificaciones
      --END IF;
      v_pasexec := 40;

      IF (NVL(pnpoliza_in, 0) <> 0
          AND vnpoliza <> pnpoliza_in) THEN
         v_pasexec := 41;
         RETURN 9906019;   --La póliza no es del caso recibido
      END IF;

      v_pasexec := 50;

      IF (NVL(pnpoliza_in, 0) <> 0) THEN
         v_pasexec := 51;

         SELECT COUNT(*)
           INTO vaux
           FROM seguros
          WHERE npoliza = pnpoliza_in
            AND ncertif = 0;

         IF vaux = 0 THEN
            v_pasexec := 52;
            RETURN 9906020;   --Pòlissa informada no existeix en iAxis
         END IF;
      END IF;

      v_pasexec := 60;

      IF (NVL(psproduc_in, 0) <> 0) THEN
         v_pasexec := 61;

         IF vsproduc <> psproduc_in THEN
            v_pasexec := 62;
            RETURN 9906032;   --El producto no es el del caso recibido
         END IF;
      END IF;

      pncaso_bpm_out := vncaso_bpm;
      pnsolici_bpm_out := vnsolici_bpm;
      pnnumcaso_out := vnnumcaso;
      v_pasexec := 70;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_valida_caso_bpm;

   /*********************************************************************************************************************
    * Funcion f_set_riesgo_asegurables
    *
    * Esta función se utiliza  cuando desde BPM se llama a iAxis con la interfase 9 - Notificar riesgos asegurables.
      Bug 28129 - FPG - 26-11-2013. En la interfase 'Notificar riesgos asegurables' el BPM enviará
      el código de suplemento de iAxis en vez de INCLUSION / MODIFICACION / EXCLUSION.
      Se cambia el parámetro pctipmov_bpm_in por pcmotmov_in.

        Parámetros de entrada:
           pcempres_in NUMBER
           pnnumcasop_in NUMBER
           pncaso_bpm_in NUMBER
           pnpoliza_in NUMBER
           psproduc_in NUMBER
           pnsolici_bpm_in NUMBER
         --  pctipmov_bpm_in NUMBER
           pcmotmov_in NUMBER
           pcaprobada_bpm_in NUMBER
           pcusuasignado_in VARCHAR2
           pctipide_in NUMBER
           pnnumide_in VARCHAR2

        Parámetros de salida:
           pnnumcaso_out NUMBER

    Retorno: 0 si resultado correcto, 1 si error
    **********************************************************************************************************************/
   FUNCTION f_set_riesgo_asegurable(
      pcempres_in NUMBER,
      pnnumcasop_in NUMBER,
      pncaso_bpm_in NUMBER,
      pnpoliza_in NUMBER,
      psproduc_in NUMBER,
      pnsolici_bpm_in NUMBER,
      pcmotmov_in NUMBER,
      pcaprobada_bpm_in NUMBER,
      pcusuasignado_in VARCHAR2,
      pctipide_in NUMBER,
      pnnumide_in VARCHAR2,
      pnnumcaso_out OUT NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(100) := 'PAC_GESTIONBPM.f_set_riesgo_asegurables';
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(1000)
         := 'Parametros: pcempres_in= ' || pcempres_in || ' pnnumcasop_in= ' || pnnumcasop_in
            || ' pncaso_bpm_in= ' || pncaso_bpm_in || ' pncaso_bpm_in= ' || pncaso_bpm_in
            || ' pnpoliza_in= ' || pnpoliza_in || ' psproduc_in= ' || psproduc_in
            || ' pnsolici_bpm_in= ' || pnsolici_bpm_in || ' pcmotmov_in= ' || pcmotmov_in
            || ' pcaprobada_bpm_in= ' || pcaprobada_bpm_in || ' pcusuasignado_in= '
            || pcusuasignado_in || ' pctipide_in= ' || pctipide_in || ' pnnumide_in= '
            || pnnumide_in;
      -- Bug 28129- FPG - 2013-11-26 - inicio
      --v_cmotmov      NUMBER;
      vctipmov_bpm   NUMBER;
      vcmovseg       NUMBER;
   -- Bug 28129- FPG - 2013-11-26 - final
   BEGIN
      --Si se pasan todas las validaciones hay que:
      --  Obtener el nº de caso BPm interno de iAxis de la secuencia SEQ_CASOS_BPM_NNUMCASO
      SELECT seq_casos_bpm_nnumcaso.NEXTVAL
        INTO pnnumcaso_out
        FROM DUAL;

      v_pasexec := 10;

      -- Bug 28129- FPG - 2013-11-26 - inicio
--      IF (pctipmov_bpm_in = 10) THEN   -- Inclusión asegurado
--         v_pasexec := 11;
--         v_cmotmov := 100;
--      ELSE
--         v_pasexec := 12;
--         v_cmotmov := 0;
--      END IF;

      --      v_pasexec := 20;

      --      INSERT INTO casos_bpm
--                  (cempres, nnumcaso, cusuasignado, ctipoproceso, cestado, cestadoenvio,
--                   fbaja, sproduc, cmotmov, ctipide, nnumide, tnomcom, npoliza, ncertif,
--                   nmovimi, nnumcasop, ncaso_bpm, nsolici_bpm, ctipmov_bpm,
--                   caprobada_bpm)
--           VALUES (pcempres_in, pnnumcaso_out, pcusuasignado_in, 1, 1, 0,
--                   NULL, psproduc_in, 100, pctipide_in, pnnumide_in, NULL, pnpoliza_in, NULL,
--                   NULL, pnnumcasop_in, pncaso_bpm_in, pnsolici_bpm_in, pctipmov_bpm_in,
--                   pcaprobada_bpm_in);

      --Calcular el campo CTIPMOV_BPM de la siguiente forma
       -- Si pcmotmov = 100 entonces CTIPMOV_BPM = 10 - Inclusión asegurado
       -- Si no, obtener el campo cmovseg de la tabla CODIMOTMOV
       -- Si cmovseg = 4 entonces CTIPMOV_BPM = 13- Rehabilitación asegurado
      -- Si cmovseg = 3 entonces CTIPMOV_BPM = 12- Exclusión asegurado
      -- En caso contrario CTIPMOV_BPM = 11- Modificación asegurado
      IF (pcmotmov_in = 100) THEN
         v_pasexec := 11;
         vctipmov_bpm := 10;
      ELSE
         v_pasexec := 13;

         BEGIN
            SELECT cmovseg
              INTO vcmovseg
              FROM codimotmov
             WHERE cmotmov = pcmotmov_in;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcmovseg := 0;
         END;

         IF vcmovseg = 4 THEN
            v_pasexec := 14;
            vctipmov_bpm := 13;
         ELSIF vcmovseg = 3 THEN
            v_pasexec := 15;
            vctipmov_bpm := 12;
         ELSE
            v_pasexec := 16;
            vctipmov_bpm := 11;
         END IF;
      END IF;

      v_pasexec := 20;

      INSERT INTO casos_bpm
                  (cempres, nnumcaso, cusuasignado, ctipoproceso, cestado, cestadoenvio,
                   fbaja, sproduc, cmotmov, ctipide, nnumide, tnomcom,
                   npoliza, ncertif, nmovimi, nnumcasop, ncaso_bpm, nsolici_bpm,
                   ctipmov_bpm, caprobada_bpm)
           VALUES (pcempres_in, pnnumcaso_out, pcusuasignado_in, 1, 1, 0,
                   NULL, psproduc_in, pcmotmov_in, pctipide_in, pnnumide_in, NULL,
                   pnpoliza_in, NULL, NULL, pnnumcasop_in, pncaso_bpm_in, pnsolici_bpm_in,
                   vctipmov_bpm, pcaprobada_bpm_in);

      -- Bug 28129- FPG - 2013-11-26 - final
      v_pasexec := 30;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_set_riesgo_asegurable;

   /*********************************************************************************************************************
   * Funcion f_upd_casos_bpm_doc
    *
    * Esta función se utiliza  cuando desde BPM se llama a iAxis con la interfase 13 - Notificar actualización documental o
        cuando desde iAxis se tiene que actualizar el estado de un documento
     Bug 28129 - FPG - 26-11-2013 Modificar el tipo del campo idgestordocbpm de NUMBER a VARCHAR2
    Parámetros de entrada:
       pcempres_in NUMBER - Empresa
       pnnumcaso_in NUMBER: número del caso interno de iAxis
       --pidgestordocbpm_in NUMBER: Id del documento en el gestor documental del BPM
       pidgestordocbpm_in VARCHAR2: Id del documento en el gestor documental del BPM
       pcdocume_in NUMBER: Código de documento
       pcestadodoc_in NUMBER: Estado del documento VF 965
       piddoc_In NUMBER: Id del documento en Gedox

    Retorno: 0 si resultado correcto, código del error en caso contrario

    **********************************************************************************************************************/
   FUNCTION f_upd_casos_bpm_doc(
      pcempres_in IN NUMBER,
      pnnumcaso_in IN NUMBER,
      pidgestordocbpm_in IN VARCHAR2,
      pcdocume_in IN NUMBER,
      pcestadodoc_in IN NUMBER,
      piddoc_in IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(100) := 'PAC_GESTIONBPM.f_upd_casos_bpm_doc';
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(1000)
         := 'Parametros: pcempres_in= ' || pcempres_in || ' pnnumcaso_in= ' || pnnumcaso_in
            || ' pidgestordocbpm_in= ' || pidgestordocbpm_in || ' pcdocume_in= '
            || pcdocume_in || ' pcestadodoc_in= ' || pcestadodoc_in || ' piddoc_in= '
            || piddoc_in;
   BEGIN
      UPDATE casos_bpm_doc
         SET cdocume = pcdocume_in,
             cestadodoc = pcestadodoc_in,
             iddoc = NVL(piddoc_in, iddoc)
       WHERE cempres = pcempres_in
         AND nnumcaso = pnnumcaso_in
         AND idgestordocbpm = pidgestordocbpm_in;

      v_pasexec := 10;

      --Comprobar el nº de registros actualizados con la sentencia SQL%ROWCOUNT.
      --Si SQL%ROWCOUNT <> 1 devolver error --> No se ha actualizado el documento requerido
      IF SQL%ROWCOUNT <> 1 THEN
         v_pasexec := 11;
         RETURN 9906033;
      END IF;

      v_pasexec := 20;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_upd_casos_bpm_doc;

   /*********************************************************************************************************************
    * Funcion f_reasignar_caso
    *
    * Esta función se utiliza  cuando desde BPM se llama a iAxis con la interfase 16 - Reasignar caso.
        Parámetros de entrada:
         Pcempres_in NUMBER - Empresa
             Pnnumcaso_in NUMBER - número del caso interno de iAxis
         Pcusuasginado_in VARCHAR2 - Usuario al que se asigna el caso

        Retorno: 0 si resultado correcto, código del error en caso contrario

    **********************************************************************************************************************/
   FUNCTION f_reasignar_caso(pcempres_in NUMBER, pnnumcaso_in NUMBER, pcusuasginado_in VARCHAR2)
      RETURN NUMBER IS
      v_object       VARCHAR2(100) := 'PAC_GESTIONBPM.f_reasignar_caso';
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(1000)
         := 'Parametros: pcempres_in= ' || pcempres_in || ' pnnumcaso_in= ' || pnnumcaso_in
            || ' pcusuasginado_in= ' || pcusuasginado_in;
   BEGIN
      --Actualizar el registro en la tabla CASOS_BPM con los siguientes valores:
      UPDATE casos_bpm
         SET cusuasignado = pcusuasginado_in
       WHERE cempres = pcempres_in
         AND nnumcaso = pnnumcaso_in;

      v_pasexec := 10;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_reasignar_caso;

   /*********************************************************************************************************************
      * Funcion f_upd_mov_colectivo
      *
      * updatear la tabla CASOS_BPM

      Parámetros de entrada:
         pcempres_in  NUMBER - Empresa
         pnnumcaso_in NUMBER: número del caso interno de iAxis
         psproduc_in  NUMBER: Id del producto
         pnpoliza_in NUMBER: num poliza
         pcmotmov_in NUMBER: motivo movimiento

      Retorno: 0 si resultado correcto, código del error en caso contrario
    **********************************************************************************************************************/
   FUNCTION f_upd_mov_colectivo(
      pcempres_in NUMBER,
      pnnumcaso_in NUMBER,
      psproduc_in NUMBER,
      pnpoliza_in NUMBER,
      pcmotmov_in NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(100) := 'PAC_GESTIONBPM.f_upd_mov_colectivo';
      v_pasexec      NUMBER(8) := 0;
      v_param        VARCHAR2(1000)
         := 'Parametros: pcempres_in= ' || pcempres_in || ' pnnumcaso_in= ' || pnnumcaso_in
            || ' psproduc_in= ' || psproduc_in || ' pnpoliza_in= ' || pnpoliza_in
            || ' pcmotmov_in= ' || pcmotmov_in;
      vctipmov_bpm   NUMBER;
      vcmovseg       NUMBER;
   BEGIN
      v_pasexec := 10;

      --Calcular el campo CTIPMOV_BPM de la siguiente forma
         --  Si pcmotmov_in = 996 ó 997 entonces vctipmov_bpm = 2 - Novedades de asegurados (Altas/Bajas/Modif)
         --  Si pcmotmov = 100 entonces CTIPMOV_BPM = 1 - Creación certificado 0
         --  Si no, obtener el campo cmovseg de la tabla CODIMOTMOV
         --  Si cmovseg = 4 entonces CTIPMOV_BPM = 5 - Rehabilitación certificado 0
         --  Si cmovseg = 3 entonces CTIPMOV_BPM = 4 - Anulación certificado 0
         --  En caso contrario CTIPMOV_BPM  = 3 - Suplemento certificado 0
      IF (pcmotmov_in = 100) THEN
         v_pasexec := 11;
         vctipmov_bpm := 1;
      ELSIF(pcmotmov_in = 996
            OR pcmotmov_in = 997) THEN
         v_pasexec := 12;
         vctipmov_bpm := 2;   -- Novedades de asegurados (Altas/Bajas/Modif))
      ELSE
         v_pasexec := 13;

         BEGIN
            SELECT cmovseg
              INTO vcmovseg
              FROM codimotmov
             WHERE cmotmov = pcmotmov_in;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcmovseg := 0;
         END;

         IF vcmovseg = 4 THEN
            v_pasexec := 14;
            vctipmov_bpm := 5;
         ELSIF vcmovseg = 3 THEN
            v_pasexec := 15;
            vctipmov_bpm := 4;
         ELSE
            v_pasexec := 16;
            vctipmov_bpm := 3;
         END IF;
      END IF;

      v_pasexec := 10;

      UPDATE casos_bpm
         SET sproduc = psproduc_in,
             npoliza = pnpoliza_in,
             cmotmov = pcmotmov_in,
             cestado = 1,
             cestadoenvio = 0,
             ctipmov_bpm = vctipmov_bpm,
             cusuasignado = NULL
       WHERE cempres = pcempres_in
         AND nnumcaso = pnnumcaso_in;

      v_pasexec := 20;

      --Comprobar el nº de registros actualizados con la sentencia SQL%ROWCOUNT.
      --Si SQL%ROWCOUNT <> 1 devolver error
      IF SQL%ROWCOUNT <> 1 THEN
         v_pasexec := 11;
         RETURN 9906033;
      END IF;

      v_pasexec := 30;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_upd_mov_colectivo;

/*************************************************************************
      Valida los datos del caso bpm segun el parametro operacion (si es una anulación, suplemento, rehabilitacion,..)
      param in pncaso_bpm: Numero de caso BPM
               pnsolici_bpm: Numero de solicitud BPM
               psproduc: Código del producto
               pnpoliza: Número de póliza
               pncertif: NNúmero de certificado
               pcempres: cod empresa.
               poperacion : Tipo de operacion.
      return : 0 todo correcto
               <> 0 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_datosbpm(
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcempres IN NUMBER,
      poperacion IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pncaso_bpm:' || pncaso_bpm || ' pnsolici_bpm:' || pnsolici_bpm || ' psproduc:'
            || psproduc || ' pnpoliza:' || pnpoliza || ' pncertif:' || pncertif
            || ' pcempres:' || pcempres || ' poperacion:' || poperacion;
      vobject        VARCHAR2(200) := 'PAC_GESTIONBPM.f_valida_datosbpm';
      v_nerror       NUMBER;
      vnpoliza       NUMBER;
      vcestado       NUMBER;
      vctipmov_bpm   NUMBER;
      vcusuasignado  VARCHAR2(100);
      vcount         NUMBER;
      vctipide       NUMBER;
      vnnumide       VARCHAR2(50);
      vctipide2      NUMBER;
      vnnumide2      VARCHAR2(50);
      vfbaja         DATE;
      vcaprobada_bpm NUMBER;
   BEGIN
      IF pncertif = 0 THEN
         IF pncaso_bpm IS NULL THEN
            IF NVL(pac_parametros.f_parproducto_n(psproduc, 'BPM_EMISION'), 0) = 1 THEN
               BEGIN
                  SELECT COUNT(*)
                    INTO vcount
                    FROM casos_bpm
                   WHERE npoliza = pnpoliza
                     AND ncertif = 0
                     AND cempres = pcempres
                     AND fbaja IS NULL
                     AND caprobada_bpm = 1
                     AND cestado IN(1, 10);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     RETURN 0;
               END;

               IF (vcount > 0) THEN
                  RETURN 9906089;   --Hay un caso BPM que hay que gestionar
               END IF;
            ELSE
               RETURN 0;
            END IF;
         ELSE
            IF NVL(pac_parametros.f_parproducto_n(psproduc, 'BPM_EMISION'), 0) = 0 THEN
               RETURN 9904610;   --Producto sin BPM en la emisión
            END IF;

            BEGIN
               SELECT cestado, ctipmov_bpm, npoliza, cusuasignado, fbaja, caprobada_bpm
                 INTO vcestado, vctipmov_bpm, vnpoliza, vcusuasignado, vfbaja, vcaprobada_bpm
                 FROM casos_bpm
                WHERE ncaso_bpm = pncaso_bpm
                  AND nsolici_bpm = 0
                  AND cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 9906039;   -- Caso BPM inexistente
            END;

            IF vfbaja IS NOT NULL THEN
               RETURN 9906140;   --El caso BPM está dado de baja.
            END IF;

            IF vcaprobada_bpm <> 1 THEN
               RETURN 9906141;   --El caso BPM no está aprobado.
            END IF;

            IF vcusuasignado <> pac_md_common.f_get_cxtusuario THEN
               RETURN 9906048;   -- El usuario del caso no corresponde al usuario conectado
            END IF;

            IF vnpoliza IS NOT NULL THEN
               IF pnpoliza != vnpoliza THEN
                  RETURN 9906092;   --El caso BPM no corresponde a la póliza seleccionada
               END IF;
            END IF;

            IF vcestado != 1 THEN
               --RETURN 9906237;   -- El caso BPM no está en estado "Caso recibido en iAxis" ni en "Caso seleccioando en iAxis"
               RETURN 9906047;   -- El caso BPM no esta en estado "Caso recibido en iAXIS"
            END IF;

            IF ((poperacion = 'SUPLEMENTO'
                 AND vctipmov_bpm != 3)
                OR(poperacion = 'ANULACION'
                   AND vctipmov_bpm != 4)
                OR(poperacion = 'REHABILITACION'
                   AND vctipmov_bpm != 5)) THEN
               RETURN 9906142;   --El tipo de movimiento del caso BPM no se corresponde con el de la póliza.
            END IF;
         END IF;
      ELSE
         IF pncaso_bpm IS NULL
            AND pnsolici_bpm IS NULL THEN
            IF NVL(pac_parametros.f_parproducto_n(psproduc, 'BPM_EMISION'), 0) = 1 THEN
               BEGIN
                  SELECT COUNT(nnumcaso)
                    INTO vcount
                    FROM casos_bpm
                   WHERE npoliza = pnpoliza
                     AND ncertif = 0
                     AND(cestado = 1
                         OR cestado = 10)
                     AND cempres = pcempres
                     AND fbaja IS NULL
                     AND caprobada_bpm = 1;
               END;

               IF vcount = 0 THEN
                  RETURN 0;
               ELSE
                  RETURN 9906089;   --Hay un caso BPM que hay que gestionar
               END IF;
            ELSE
               RETURN 0;
            END IF;
         ELSE
            IF NVL(pac_parametros.f_parproducto_n(psproduc, 'BPM_EMISION'), 0) = 0 THEN
               RETURN 9904610;   ---Producto sin BPM en la emisión
            END IF;

            BEGIN
               SELECT cestado, ctipmov_bpm, npoliza, fbaja, caprobada_bpm
                 INTO vcestado, vctipmov_bpm, vnpoliza, vfbaja, vcaprobada_bpm
                 FROM casos_bpm
                WHERE ncaso_bpm = pncaso_bpm
                  AND nsolici_bpm = 0
                  AND cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 9906039;   -- Caso BPM inexistente
            END;

            IF vfbaja IS NOT NULL THEN
               RETURN 9906140;   --El caso BPM está dado de baja.
            END IF;

            IF vcaprobada_bpm <> 1 THEN
               RETURN 9906141;   --El caso BPM no está aprobado.
            END IF;

            IF vcestado != 1
               AND vcestado != 10 THEN
               RETURN 9906237;   -- El caso BPM no está en estado "Caso recibido en iAxis" ni en "Caso seleccioando en iAxis"'
            END IF;

            IF vctipmov_bpm != 2 THEN
               RETURN 9906109;   --El caso BPM no tiene tipo movimiento BPM "Novedades de asegurados (Altas/Bajas/Modif)"
            END IF;

            IF vnpoliza != pnpoliza THEN
               RETURN 9906092;   --El caso BPM no corresponde a la póliza seleccionada
            END IF;

            BEGIN
               SELECT p.ctipide, p.nnumide
                 INTO vctipide, vnnumide
                 FROM seguros s, tomadores t, per_personas p
                WHERE s.sseguro = t.sseguro
                  AND s.npoliza = pnpoliza
                  AND s.ncertif = pncertif
                  AND t.sperson = p.sperson
                  AND cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vctipide := -1;
                  vnnumide := '*';
            END;

            BEGIN
               SELECT cestado, ctipmov_bpm, npoliza, cusuasignado, fbaja,
                      caprobada_bpm, ctipide, nnumide
                 INTO vcestado, vctipmov_bpm, vnpoliza, vcusuasignado, vfbaja,
                      vcaprobada_bpm, vctipide2, vnnumide2
                 FROM casos_bpm
                WHERE ncaso_bpm = pncaso_bpm
                  AND nsolici_bpm = pnsolici_bpm
                  AND cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 9906168;   -- Número de caso / solicitud BPM inexistente
            END;

            IF vfbaja IS NOT NULL THEN
               RETURN 9906140;   --El caso BPM está dado de baja.
            END IF;

            IF vcaprobada_bpm <> 1 THEN
               RETURN 9906100;   -- Solicitud BPM no aprobada, no se puede seleccionar
            END IF;

            IF vcusuasignado <> pac_md_common.f_get_cxtusuario THEN
               RETURN 9906048;   -- El usuario del caso no corresponde al usuario conectado
            END IF;

            IF vcestado != 1 THEN
               RETURN 9906238;   --El caso-solicitud BPM no está en estado "Caso recibido en iAxis"
            END IF;

            IF ((poperacion = 'SUPLEMENTO'
                 AND vctipmov_bpm != 11)
                OR(poperacion = 'ANULACION'
                   AND vctipmov_bpm != 12)
                OR(poperacion = 'REHABILITACION'
                   AND vctipmov_bpm != 13)) THEN
               RETURN 9906142;   --El tipo de movimiento del caso BPM no se corresponde con el de la póliza.
            END IF;

            IF vnpoliza != pnpoliza THEN
               RETURN 9906092;   --El caso BPM no corresponde a la póliza seleccionada
            END IF;

            IF vctipide <> vctipide2 THEN
               RETURN 9906143;   --El tipo de documento del tomador del caso BPM no se corresponde con el de la póliza.
            END IF;

            IF vnnumide <> vnnumide2 THEN
               RETURN 9906144;   --El número de documento del tomador del caso BPM no se corresponde con el de la póliza.
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_valida_datosbpm;

/***************************************************************************************
    * Funcion f_get_tomcaso
    * Funcion que devuelve el nombre del tomador del cso BPM
    *
    * Parametros: pnnumcaso: Numero de caso
    *             pncaso_bpm: Numero de caso BPM
    *             pnsolici_bpm: Numero de solicitud BPM
    *             pcempres: Código de la empresa
    *             ptnomcom: Nombre completo del tomador
    *
    * Return: 0 OK, otro valor error.
    ****************************************************************************************/
   FUNCTION f_get_tomcaso(
      pnnumcaso IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      pcempres IN NUMBER,
      ptnomcom OUT VARCHAR2,
      pnnumcaso_out OUT NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(100) := 'PAC_GESTIONBPM.F_GET_TOMCASO';
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(1000)
         := 'Parametros: pnnumcaso= ' || pnnumcaso || ' pncaso_bpm=' || pncaso_bpm
            || ' pnsolici_bpm:' || pnsolici_bpm || ' pcempres= ' || pcempres;
      vnnumcaso      NUMBER;
      vnsolici_bpm   NUMBER;
      vncaso_bpm     NUMBER;
      vcaprobada_bpm NUMBER;
      vfbaja         DATE;
   BEGIN
      IF pnnumcaso IS NOT NULL THEN
         pnnumcaso_out := pnnumcaso;

         BEGIN
            SELECT NVL(tnomcom, '**'), nsolici_bpm, ncaso_bpm, caprobada_bpm, fbaja
              INTO ptnomcom, vnsolici_bpm, vncaso_bpm, vcaprobada_bpm, vfbaja
              FROM casos_bpm
             WHERE nnumcaso = pnnumcaso
               AND cempres = pcempres;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9906039;   -- Caso BPM inexistente
         END;

         IF vcaprobada_bpm = 0 THEN
            RETURN 9906141;   -- El caso BPM no está aprobado.
         END IF;

         IF vfbaja IS NOT NULL THEN
            RETURN 9906140;   -- El caso BPM está dado de baja.
         END IF;

         IF NVL(vnsolici_bpm, 0) != 0 THEN
            BEGIN
               SELECT NVL(tnomcom, '**'), caprobada_bpm, fbaja
                 INTO ptnomcom, vcaprobada_bpm, vfbaja
                 FROM casos_bpm
                WHERE ncaso_bpm = vncaso_bpm
                  AND nsolici_bpm = 0
                  AND cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 9906039;   -- Caso BPM inexistente
            END;

            IF vcaprobada_bpm = 0 THEN
               RETURN 9906141;   -- El caso BPM no está aprobado.
            END IF;

            IF vfbaja IS NOT NULL THEN
               RETURN 9906140;   -- El caso BPM está dado de baja.
            END IF;
         END IF;
      ELSE
         IF pnsolici_bpm IS NULL THEN
            BEGIN
               SELECT NVL(tnomcom, '**'), nnumcaso, caprobada_bpm, fbaja
                 INTO ptnomcom, pnnumcaso_out, vcaprobada_bpm, vfbaja
                 FROM casos_bpm
                WHERE ncaso_bpm = pncaso_bpm
                  AND nsolici_bpm = 0
                  AND cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 9906039;   -- Caso BPM inexistente
            END;

            IF vcaprobada_bpm = 0 THEN
               RETURN 9906141;   -- El caso BPM no está aprobado.
            END IF;

            IF vfbaja IS NOT NULL THEN
               RETURN 9906140;   -- El caso BPM está dado de baja.
            END IF;
         ELSE
            BEGIN
               SELECT nnumcaso, caprobada_bpm, fbaja
                 INTO pnnumcaso_out, vcaprobada_bpm, vfbaja
                 FROM casos_bpm
                WHERE ncaso_bpm = pncaso_bpm
                  AND nsolici_bpm = pnsolici_bpm
                  AND cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 9906168;   -- Número de caso / solicitud BPM inexistente
            END;

            IF vcaprobada_bpm = 0 THEN
               RETURN 9906100;   -- Solicitud BPM no aprobada, no se puede seleccionar
            END IF;

            IF vfbaja IS NOT NULL THEN
               RETURN 9906140;   -- El caso BPM está dado de baja.
            END IF;

            BEGIN
               SELECT NVL(tnomcom, '**'), caprobada_bpm, fbaja
                 INTO ptnomcom, vcaprobada_bpm, vfbaja
                 FROM casos_bpm
                WHERE ncaso_bpm = pncaso_bpm
                  AND nsolici_bpm = 0
                  AND cempres = pcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 9906039;   -- Caso BPM inexistente
            END;

            IF vcaprobada_bpm = 0 THEN
               RETURN 9906141;   -- El caso BPM no está aprobado.
            END IF;

            IF vfbaja IS NOT NULL THEN
               RETURN 9906140;   -- El caso BPM está dado de baja.
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_get_tomcaso;

   /*************************************************************************
       Valida los datos del caso bpm para certificados
       param in pncaso_bpm: Numero de caso BPM
                pnsolici_bpm: Numero de solicitud BPM
                psproduc: Código del producto
                pnpoliza: Número de póliza
       return : 0 todo correcto
                <> 0 ha habido un error

       Bug 28263/153355 - 07/10/2013 - AMC
    *************************************************************************/
   FUNCTION f_valida_datosbpmcertif(
      pcempres IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pcempres: ' || pcempres || ' pncaso_bpm:' || pncaso_bpm || ' pnsolici_bpm:'
            || pnsolici_bpm || ' psproduc:' || psproduc || ' pnpoliza:' || pnpoliza;
      vobject        VARCHAR2(200) := 'PAC_GESTIONBPM.f_valida_datosbpmcertif';
      v_nerror       NUMBER;
      vnpoliza       NUMBER;
      vcestado       NUMBER;
      vctipmov_bpm   NUMBER;
      vcaprobada_bpm NUMBER;
      vfbaja         DATE;
      vcount         NUMBER;
   BEGIN
      IF pncaso_bpm IS NULL
         AND pnsolici_bpm IS NULL THEN
         IF NVL(pac_parametros.f_parproducto_n(psproduc, 'BPM_EMISION'), 0) = 1 THEN
            BEGIN
               SELECT COUNT(*)
                 INTO vcount
                 FROM casos_bpm
                WHERE cempres = pcempres
                  AND npoliza = pnpoliza
                  AND ncertif = 0
                  AND cempres = pcempres
                  AND fbaja IS NULL
                  AND caprobada_bpm = 1
                  AND cestado IN(1, 10);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 0;
            END;

            IF (vcount > 0) THEN
               RETURN 9906089;   --Hay un caso BPM que hay que gestionar
            END IF;
         ELSE
            RETURN 0;
         END IF;
      ELSE
         IF NVL(pac_parametros.f_parproducto_n(psproduc, 'BPM_EMISION'), 0) = 0 THEN
            RETURN 9904610;
         END IF;

         BEGIN
            SELECT cestado, ctipmov_bpm, npoliza, caprobada_bpm, fbaja
              INTO vcestado, vctipmov_bpm, vnpoliza, vcaprobada_bpm, vfbaja
              FROM casos_bpm
             WHERE cempres = pcempres
               AND ncaso_bpm = pncaso_bpm
               AND nsolici_bpm = 0;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9906039;   -- Caso BPM inexistente
         END;

         IF vfbaja IS NOT NULL THEN
            RETURN 9906140;   -- El caso BPM está dado de baja
         END IF;

         IF vcaprobada_bpm = 0 THEN
            RETURN 9906141;   -- El caso BPM no está aprobado.
         END IF;

         IF vcestado != 1
            AND vcestado != 10 THEN
            RETURN 9906237;   -- El caso BPM no está en estado "Caso recibido en iAxis" ni en "Caso seleccioando en iAxis"
         END IF;

         IF pnpoliza != vnpoliza THEN
            RETURN 9906092;   -- El caso BPM no corresponde a la póliza seleccionada
         END IF;

         BEGIN
            SELECT cestado, caprobada_bpm, fbaja
              INTO vcestado, vcaprobada_bpm, vfbaja
              FROM casos_bpm
             WHERE cempres = pcempres
               AND ncaso_bpm = pncaso_bpm
               AND nsolici_bpm = pnsolici_bpm;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9906168;   -- Número de caso / solicitud BPM inexistente
         END;

         IF vfbaja IS NOT NULL THEN
            RETURN 9906140;   -- El caso BPM está dado de baja.
         END IF;

         IF vcaprobada_bpm = 0 THEN
            RETURN 9906100;   -- Solicitud BPM no aprobada, no se puede seleccionar
         END IF;

         IF vcestado != 1 THEN
            RETURN 9906238;   -- 'El caso-solicitud BPM no está en estado "Caso recibido en iAxis"'
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_valida_datosbpmcertif;

   /*************************************************************************
       grabar registro en la tabla CASOS_BPMSEG
       param in pcempres_in
                psseguro:     identificador del seguro
                pnmovimi:     número de movimiento de seguro
                pncaso_bpm:   número del caso en el BPM
                pnsolici_bpm: número de la solicitud en el BPM
                pnnumcaso:    número del caso interno de iAxis
       return : 0 todo correcto
                <> 0 ha habido un error
    *************************************************************************/
   FUNCTION f_set_caso_bpmseg(
      pcempres_in IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pncaso_bpm IN NUMBER,
      pnsolici_bpm IN NUMBER,
      pnnumcaso IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pcempres_in:' || pcempres_in || ' psseguro:' || psseguro || ' pnmovimi:'
            || pnmovimi || ' pncaso_bpm:' || pncaso_bpm || ' pnsolici_bpm:' || pnsolici_bpm
            || ' pnnumcaso:' || pnnumcaso;
      vobject        VARCHAR2(200) := 'PAC_GESTIONBPM.f_set_caso_bpmseg';
      v_nerror       NUMBER;
      vnumcaso       NUMBER;
      v_ncaso_bpm    NUMBER;
      v_nsolici_bpm  NUMBER;
      vnummov        NUMBER;
   BEGIN
      vpasexec := 10;

      IF pcempres_in IS NULL
         OR psseguro IS NULL
         OR(NVL(pnnumcaso, 0) = 0
            AND NVL(pncaso_bpm, 0) = 0
            AND NVL(pnsolici_bpm, 0) = 0) THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 20;

      --Si pnnumcaso no está informado, obtenerlo leyendo la tabla CASOS_BPM con ncaso_bpm / nsolici_bpm.
      IF (NVL(pnnumcaso, 0) = 0) THEN
         vpasexec := 30;

         BEGIN
            SELECT nnumcaso
              INTO vnumcaso
              FROM casos_bpm
             WHERE cempres = pcempres_in
               AND ncaso_bpm = pncaso_bpm
               AND nsolici_bpm = pnsolici_bpm;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9906168;   -- Número de caso / solicitud BPM inexistente
         END;
      ELSE
         vpasexec := 40;
         vnumcaso := pnnumcaso;

         BEGIN
            SELECT ncaso_bpm, nsolici_bpm
              INTO v_ncaso_bpm, v_nsolici_bpm
              FROM casos_bpm
             WHERE cempres = pcempres_in
               AND nnumcaso = pnnumcaso;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 9906168;   -- Número de caso / solicitud BPM inexistente
         END;

         vpasexec := 50;

         IF pncaso_bpm IS NOT NULL THEN
            vpasexec := 51;

            IF pncaso_bpm <> v_ncaso_bpm THEN
               vpasexec := 52;
               RAISE e_param_error;
            END IF;
         END IF;

         vpasexec := 55;

         IF pnsolici_bpm IS NOT NULL THEN
            vpasexec := 56;

            IF NVL(pnsolici_bpm, 0) <> v_nsolici_bpm THEN
               vpasexec := 57;
               RAISE e_param_error;
            END IF;
         END IF;
      END IF;

      vpasexec := 10;

      IF (pnmovimi IS NULL) THEN
         vpasexec := 11;

         SELECT MAX(nmovimi)
           INTO vnummov
           FROM movseguro
          WHERE sseguro = psseguro;
      ELSE
         vnummov := pnmovimi;
      END IF;

      vpasexec := 20;

      INSERT INTO casos_bpmseg
                  (sseguro, nmovimi, cempres, nnumcaso, cactivo)
           VALUES (psseguro, vnummov, pcempres_in, vnumcaso, 1);

      vpasexec := 30;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(1000005));
         RETURN 1000005;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_set_caso_bpmseg;

   /*************************************************************************
      Valida los datos del caso bpm para cargas
      param in pncaso_bpm: Numero de caso BPM
               pnnumcaso: Numero de caso
               pfichero: nombre del fichero

      return : 0 todo correcto
               <> 0 ha habido un error

      Bug 28263/155558 - 14/10/2013 - AMC
   *************************************************************************/
   FUNCTION f_valida_datosbpmcarga(
      pncaso_bpm IN NUMBER,
      pnnumcaso IN NUMBER,
      pfichero IN VARCHAR2,
      pusuario IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pncaso_bpm:' || pncaso_bpm || ' pnnumcaso:' || pnnumcaso || ' pfichero:'
            || pfichero || ' pusuario:' || pusuario;
      vobject        VARCHAR2(200) := 'PAC_GESTIONBPM.f_valida_datosbpmcarga';
      v_nerror       NUMBER;
      vcount         NUMBER;
      v_ss           VARCHAR2(3000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      v_propio       VARCHAR2(50);
      v_retorno      NUMBER;
      v_cempres      NUMBER;
      vcaprobada_bpm NUMBER;
      vfbaja         DATE;
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
   BEGIN
      vpasexec := 10;
      v_cempres := pac_md_common.f_get_cxtempresa;
      vpasexec := 11;

      SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_GESTIONBPM')
        INTO v_propio
        FROM DUAL;

      vpasexec := 20;

      SELECT 'BEGIN ' || ' :RETORNO := ' || v_propio || '.' || 'f_valida_datosbpmcarga('''
             || pncaso_bpm || ''',''' || pnnumcaso || ''',''' || pfichero || ''','''
             || pusuario || '''); END;'
        INTO v_ss
        FROM DUAL;

      vpasexec := 30;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vpasexec := 40;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vpasexec := 50;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
         vpasexec := 200;

         IF pnnumcaso IS NOT NULL THEN
            vpasexec := 210;

            BEGIN
               SELECT caprobada_bpm, fbaja
                 INTO vcaprobada_bpm, vfbaja
                 FROM casos_bpm
                WHERE cempres = v_cempres
                  AND nnumcaso = pnnumcaso;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 9906039;   -- Caso BPM inexistente
            END;
         ELSE
            vpasexec := 220;

            BEGIN
               SELECT caprobada_bpm, fbaja
                 INTO vcaprobada_bpm, vfbaja
                 FROM casos_bpm
                WHERE cempres = v_cempres
                  AND ncaso_bpm = pncaso_bpm
                  AND nsolici_bpm = 0;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 9906039;   -- Caso BPM inexistente
            END;
         END IF;

         IF vfbaja IS NOT NULL THEN
            RETURN 9906140;   -- El caso BPM está dado de baja
         END IF;

         IF vcaprobada_bpm = 0 THEN
            RETURN 9906141;   -- El caso BPM no está aprobado.
         END IF;

         RETURN 0;
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(1000006));
         RETURN 1000006;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END f_valida_datosbpmcarga;
END pac_gestionbpm;

/

  GRANT EXECUTE ON "AXIS"."PAC_GESTIONBPM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GESTIONBPM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GESTIONBPM" TO "PROGRAMADORESCSI";
