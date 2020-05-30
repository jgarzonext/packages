--------------------------------------------------------
--  DDL for Package Body PAC_MD_PRENOTIFICACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PRENOTIFICACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_PRENOTIFICACIONES
   PROPÓSITO:  Mantenimiento domiciliaciones. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/11/2011   JMF                1. 0020000: LCOL_A001-Prenotificaciones
   2.0        23/01/2012   MDS                2. 0021003: LCOL_A001-LCOLA_001 - Errores en las prenotificaciones
   3.0        09/02/2012   APD                3. 0021116: LCOL_A001-Controlar domiciliaciones y prenotificaciones por cobrador bancario
   4.0        16/02/2012   JGR                4. 0021388: Mensaje proceso prenotificacion modificar"numero de recibos cobrados" por "numero de recibos generados"
   5.0        22/11/2012   ECP                5. 0024672: LCOL_A003-Domiciliaciones - QT 0005339: Consultas en los aplciativosy validaciones pendientes
   6.0        15/05/2013   JDS                6. 0026967: LCOL_A003-No se puede regenerar el archivo plano de prenotificaciones
 ******************************************************************************/

   /**************************************************************************
        Función que inserta las domiciliaciones
        PARAM IN PSPROCES   : nº proceso de domiciliación
        PARAM IN PCEMPRES   : nº empresa
        PARAM IN PEFECTO    : fecha efecto límite de recibos
        PARAM IN PFFECCOB   : fecha de remesea de la domiciliación
        PARAM IN PCRAMO     : nº ramo
        PARAM IN PSPRODUC   : nº producto
        PARAM IN PSPRODOM   : nº proceso selección productos a domiciliar
        PARAM IN PIDIOMA   : idioma
        PARAM OUT PNOK      : nº recibos domiciliados correctamente
        PARAM OUT PNKO      : nº recibos domiciliados incorrectamente
            NomMap1 OUT VARCHAR2, --Path Completo Fichero de map 312,
            NomMap2 OUT VARCHAR2, --Path Completo Fichero de map 312,
            NomDR OUT VARCHAR2,   --Path Completo Fichero de DR,
        PARAM OUT mensaje    : Tratamiento del mensaje
        PARAM OUT NERROR     : Código de error (0: opración correcta sino error)
   *************************************************************************/
   FUNCTION f_domiciliar(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pffeccob IN DATE,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psprodom IN NUMBER,
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      pnok OUT NUMBER,
      pnko OUT NUMBER,
      sproces OUT NUMBER,
      nommap1 OUT VARCHAR2,
      nommap2 OUT VARCHAR2,
      nomdr OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpas           NUMBER := 1;
      vobj           VARCHAR2(900) := 'PAC_MD_PRENOTIFICACIONES.f_domiciliar';
      vpar           VARCHAR2(900)
         := NULL || ' psproces=' || psproces || ' pcempres=' || pcempres || ' pfefecto='
            || pfefecto || ' pffeccob=' || pffeccob || ' pcramo=' || pcramo || ' psproduc='
            || psproduc || ' psprodom=' || psprodom || ' pccobban=' || pccobban || ' pcbanco='
            || pcbanco || ' pctipcta=' || pctipcta || ' pfvtotar=' || pfvtotar
            || ' pcreferen=' || pcreferen || ' pdfefecto=' || pdfefecto;
      vparam         VARCHAR2(900);
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsqlstmt       VARCHAR2(2000);
      vrefcursor     sys_refcursor;
      v_user         cfg_user.cuser%TYPE;
      smapead        NUMBER;
      vpath          VARCHAR2(100);
      v_missatge     VARCHAR2(100);
      v_dias         NUMBER;
   BEGIN
      --Comprovació de paràmetres d'entrada
      vpas := 100;

      IF psproces IS NOT NULL
         AND(pcramo IS NOT NULL
             OR psproduc IS NOT NULL
             OR pfefecto IS NOT NULL) THEN
         vpas := 110;
         vparam := 'Parámetro - Proceso';
         RAISE e_error_controlat;
      END IF;

      vpas := 120;

      IF ((pcempres IS NULL
           AND pfefecto IS NULL)
          OR(pcempres IS NULL
             AND pfefecto IS NOT NULL)
          OR(pcempres IS NOT NULL
             AND pfefecto IS NULL))
         AND psproces IS NULL THEN
         vpas := 130;
         vparam := 'Parámetro - Empresa';
         RAISE e_error_controlat;
      END IF;

      BEGIN
         vpas := 140;

         SELECT NVL(nvalpar, 0)
           INTO v_dias
           FROM parempresas
          WHERE cparam = 'DIASDOMICI'
            AND cempres = pcempres;
      EXCEPTION
         WHEN OTHERS THEN
            -- No esta el parametro definido
            NULL;
      END;

      vpas := 150;

      IF v_dias IS NOT NULL
         AND   --si es null aleshores no tinc limitació.
            TO_DATE(TO_CHAR(pfefecto, 'dd/mm/yyyy'), 'dd/mm/yyyy') >
                               TO_DATE(TO_CHAR(f_sysdate + v_dias, 'dd/mm/yyyy'), 'dd/mm/yyyy') THEN
         vpas := 160;
         vparam := 'Parámetro - Fefecto';
         RAISE e_error_controlat;
      END IF;

      -- Bug 21116 - APD - 09/02/2012 - el cobrador bancario es obligatorio
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DOMI_COBBAN'), 0) = 1 THEN
         IF pccobban IS NULL THEN
            vparam := 'Parámetro - Cobban';
            RAISE e_error_controlat;
         ELSE
            -- Bug 21116 - APD - 27/01/2012 - Controlar que si existe una domiciliación
            -- en curso para un cobrador bancario, no permitir realizar una nueva
            -- domiciliación de este cobrador bancario (0.-No controlar, 1.-Si controlar)
            vnumerr := pac_prenotificaciones.f_valida_prenoti_cobban(pcempres, pccobban);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(vnumerr,
                                                               pac_iax_common.f_get_cxtidioma));
               RETURN vnumerr;
            END IF;
         -- fin Bug 21116 - APD - 27/01/2012
         END IF;
      END IF;

      -- fin Bug 21116 - APD - 09/02/2012
      vpas := 170;
      vnumerr := pac_prenotificaciones.f_domiciliar(psproces, pcempres, pfefecto, pffeccob,
                                                    pcramo, psproduc, psprodom, pccobban,
                                                    pcbanco, pctipcta, pfvtotar, pcreferen,
                                                    pdfefecto, pac_md_common.f_get_cxtidioma,
                                                    pnok, pnko, vpath, nommap1, nommap2, nomdr,
                                                    sproces);

      IF vnumerr = 0
         AND psproces IS NULL THEN
         vpas := 180;
         --Procés generat
         pac_iobj_mensajes.crea_nuevo_mensaje
                                           (mensajes, 2, 0,
                                            f_axis_literales(9001242,
                                                             pac_iax_common.f_get_cxtidioma)
                                            || ' ' || sproces);
         --Número de rebuts cobrats
         pac_iobj_mensajes.crea_nuevo_mensaje
                                    (mensajes, 2, 0,

                                     --f_axis_literales(9001243, --  16/02/2012 JGR 4. 0021388
                                     f_axis_literales(9903281,   --  16/02/2012 JGR 4. 0021388
                                                      pac_iax_common.f_get_cxtidioma)
                                     || ' ' || pnok);
         --Número de rebuts amb errors
         pac_iobj_mensajes.crea_nuevo_mensaje
                                           (mensajes, 2, 0,
                                            f_axis_literales(9001244,
                                                             pac_iax_common.f_get_cxtidioma)
                                            || ' ' || pnko);
         --El fitxer de domiciliacions s''ha generat correctament en la ubicació:
         pac_iobj_mensajes.crea_nuevo_mensaje
                                    (mensajes, 2, 0,

                                     --f_axis_literales(9001245, --  16/02/2012 JGR 4. 0021388
                                     f_axis_literales(9903282,   --  16/02/2012 JGR 4. 0021388
                                                      pac_iax_common.f_get_cxtidioma)
                                     || ' ' || vpath);
      ELSIF vnumerr = 0
            AND psproces IS NOT NULL THEN
         vpas := 190;
         --El fitxer de domiciliacions s''ha generat correctament en la ubicació:
         pac_iobj_mensajes.crea_nuevo_mensaje
                                           (mensajes, 2, 0,
                                            f_axis_literales(9001245,
                                                             pac_iax_common.f_get_cxtidioma)
                                            || ' ' || vpath);
      ELSIF vnumerr <> 0 THEN
         vpas := 200;
         pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(vnumerr,
                                                               pac_iax_common.f_get_cxtidioma));
         RETURN vnumerr;
      END IF;

      --Retorn del menú de l'aplicació.
      vpas := 210;
      RETURN 0;
   EXCEPTION
      WHEN e_error_controlat THEN
         IF vparam = 'Parámetro - Proceso' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9001139,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 9001139;
         ELSIF vparam = 'Parámetro - Empresa' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9001138,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 9001138;
         ELSIF vparam = 'Parámetro - Fefecto' THEN
            v_missatge := pac_iobj_mensajes.f_get_descmensaje(109208,
                                                              pac_md_common.f_get_cxtidioma);

            IF v_dias > 0 THEN
               v_missatge :=
                  v_missatge || '+' || TO_CHAR(v_dias) || ' '
                  || pac_iobj_mensajes.f_get_descmensaje(9002204,
                                                         pac_md_common.f_get_cxtidioma);
            END IF;

            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 109208, v_missatge);   -- La fecha no puede ser superior a la actual
            RETURN 109208;
         -- Bug 21116 - APD - 09/02/2012 - el cobrador bancario es obligatorio
         ELSIF vparam = 'Parámetro - Cobban' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(120081,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 120081;
         -- fin Bug 21116 - APD - 09/02/2012
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
   END f_domiciliar;

/**************************************************************************
        Función que se retorna la información de domiciliaciones
        PARAM IN PSPROCES   : nº proceso de domiciliación
        PARAM IN PCEMPRES   : nº empresa
        PARAM IN PCRAMO     : nº ramo
        PARAM IN PSPRODUC   : nº producto
        PARAM IN PEFECTO    : fecha efecto límite de recibos
        PARAM IN PSPRODOM   : nº proceso selección productos a domiciliar
        PARAM IN PCCOBBAN   : Código de cobrador bancario
        PARAM IN PCBANCO    : Código de banco
        PARAM IN PCTIPCTA   : Tipo de cuenta
        PARAM IN PFVTOTAR   : Fecha de vencimiento tarjeta
        PARAM IN PCREFEREN  : Código de referencia
        PARAM OUT mensaje    : Tratamiento del mensaje
   *************************************************************************/
   FUNCTION f_get_domiciliacion(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      psprodom IN NUMBER,
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN DATE DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobj           VARCHAR2(900) := 'PAC_MD_PRENOTIFICACIONES.f_get_domiciliacion';
      vpar           VARCHAR2(900)
         := NULL || ' psproces=' || psproces || ' pcempres=' || pcempres || ' pcramo='
            || pcramo || ' psproduc=' || psproduc || ' pfefecto=' || pfefecto || ' psprodom='
            || psprodom || ' pccobban=' || pccobban || ' pcbanco=' || pcbanco || ' pctipcta='
            || pctipcta || ' pfvtotar=' || pfvtotar || ' pcreferen=' || pcreferen
            || ' pdfefecto=' || pdfefecto;
      vparam         VARCHAR2(900);
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(2000);
      vsquery_total  VARCHAR2(9000);
      vrefcursor     sys_refcursor;
      ---
      vnum_dades     NUMBER(9) := 0;
      vempresa       VARCHAR2(400);
      vproducto      VARCHAR2(100);
      vnpoliza       VARCHAR2(20);
      vnrecibo       NUMBER;
      vtipo_recibo   VARCHAR2(100);
      vctipban_cobra NUMBER(1);
      vcobrador      VARCHAR2(100);
      vfefecto       DATE;
      vfvencim       DATE;
      vctipban_cban  NUMBER;
      vcbancar       VARCHAR2(200);
      vitotalr       NUMBER;
      vproceso       NUMBER;
      vfichero       VARCHAR2(500);
      v_estado       detvalores.tatribu%TYPE;
      v_estdomi      detvalores.tatribu%TYPE;
      v_festado      DATE;
      v_fcorte       DATE;
      v_testimp      VARCHAR2(500);
      vtomador       VARCHAR2(200);
      vcodbancar     VARCHAR2(200);
      vcont          NUMBER := 0;
      v_max_reg      parinstalacion.nvalpar%TYPE;
      vmsg           VARCHAR2(500);   -- Mostrar mensaje en pantalla si está limitado
      vcramo         NUMBER;
      vcempres       NUMBER;
      vsproduc       NUMBER;
      -- ini BUG 21003 - MDS - 25/01/2012
      -- añadir variables: sucursal,ramo,actividad,entidad_bancaria,codigo_banco,tipo_cuenta
      -- numero_cuenta,fecha_vencimientotjt
      -- numide_tomador,asegurado,numide_asegurado,pagador,numide_pagador
      -- codi_prenotificacion,codi_redbancaria
      vsucursal      VARCHAR2(200);
      vramo          ramos.tramo%TYPE;
      vactividad     seguros.cactivi%TYPE;
      ventidad_bancaria bancos.tbanco%TYPE;
      ventidad_bancaria_recibo bancos.tbanco%TYPE;
      vcodigo_banco  VARCHAR2(200);
      vtipo_cuenta   VARCHAR2(200);
      vnumero_cuenta VARCHAR2(200);
      vcodigo_banco_recibo VARCHAR2(200);
      vfecha_vencimientotjt DATE;
      vnumide_tomador per_personas.nnumide%TYPE;
      vasegurado     VARCHAR2(200);
      vnumide_asegurado per_personas.nnumide%TYPE;
      vpagador       VARCHAR2(200);
      vnumide_pagador per_personas.nnumide%TYPE;
      vcodi_prenotificacion VARCHAR2(200);
      vcodi_redbancaria cobbancario.cdoment%TYPE;
   -- fin BUG 21003 - MDS - 25/01/2012
   BEGIN
      v_max_reg := f_parinstalacion_n('N_MAX_REG');

      --CONTROL DE PARAMETROS DE ENTRADA
       --Comprovació de paràmetres d'entrada
      IF psproces IS NULL
         AND pfefecto IS NULL THEN
         vparam := 'Parámetro - Fecha Efecto nulo';
         RAISE e_error_controlat;
      END IF;

      IF psproces IS NOT NULL
         AND(pcramo IS NOT NULL
             OR psproduc IS NOT NULL
             OR pfefecto IS NOT NULL) THEN
         vparam := 'Parámetro - Proceso';
         RAISE e_error_controlat;
      END IF;

      -- Bug 21116 - APD - 09/02/2012 - el cobrador bancario es obligatorio
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'DOMI_COBBAN'), 0) = 1 THEN
         IF pccobban IS NULL THEN
            vparam := 'Parámetro - Cobban';
            RAISE e_error_controlat;
         END IF;
      END IF;

      -- fin Bug 21116 - APD - 09/02/2012

      -- BUG 21003 - MDS - 25/01/2012
      vpasexec := 2;
      vnumerr := pac_prenotificaciones.f_get_domiciliacion(psproces, pcempres, pcramo,
                                                           psproduc, pfefecto,
                                                           pac_md_common.f_get_cxtidioma,
                                                           vsquery_total, psprodom, pccobban,
                                                           pcbanco, pctipcta, pfvtotar,
                                                           pcreferen, pdfefecto);
      -- BUG 21003 - MDS - 25/01/2012
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vrefcursor := pac_md_listvalores.f_opencursor(vsquery_total, mensajes);
      -- BUG 21003 - MDS - 25/01/2012
      vpasexec := 4;

      IF vrefcursor IS NOT NULL THEN
         LOOP
            -- BUG 21003 - MDS - 25/01/2012
            -- añadir variables sucursal,ramo,actividad,entidad_bancaria,codigo_banco,tipo_cuenta
            -- numero_cuenta,fecha_vencimientotjt
            -- numide_tomador,asegurado,numide_asegurado,pagador,numide_pagador
            -- codi_prenotificacion,codi_redbancaria
            FETCH vrefcursor
             INTO vempresa, vsucursal, vramo, vproducto, vactividad, vcodbancar, vcobrador,
                  ventidad_bancaria, vcodigo_banco, vtipo_cuenta, vnumero_cuenta,
                  ventidad_bancaria_recibo, vcodigo_banco_recibo, vcbancar,
                  vfecha_vencimientotjt, vnrecibo, vnpoliza, vtipo_recibo, vtomador,
                  vnumide_tomador, vasegurado, vnumide_asegurado, vpagador, vnumide_pagador,
                  vfefecto, vfvencim, vitotalr, vcodi_prenotificacion, vproceso, vfichero,
                  v_estado, v_testimp, v_fcorte, v_estdomi, v_festado;

            vcont := vcont + 1;
            EXIT WHEN vrefcursor%NOTFOUND;
         END LOOP;

         -- BUG 21003 - MDS - 25/01/2012
         vpasexec := 5;

         --Si el cursor no te dades
         IF vempresa IS NULL THEN
            IF vrefcursor%ISOPEN THEN
               CLOSE vrefcursor;
            END IF;

            IF psproces IS NULL THEN
               pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, 0,
                                              f_axis_literales(9904558,
                                                               pac_iax_common.f_get_cxtidioma));   -- BUG 24672 - ECP - 22/11/2012 --No hi han rebuts pendents de prenotificar
            ELSE
               pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 2, 0,
                                              f_axis_literales(103778,
                                                               pac_iax_common.f_get_cxtidioma));   --Procés inexitent
            END IF;
         END IF;

         IF vcont >(v_max_reg + 1) THEN
            vmsg := f_axis_literales(9901234, pac_iax_common.f_get_cxtidioma);
            vmsg := REPLACE(vmsg, '{0}', v_max_reg);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vmsg);
         END IF;

         -- BUG 21003 - MDS - 25/01/2012
         vpasexec := 6;
         --INICIALIZAR DE NUEVO
         vrefcursor := pac_md_listvalores.f_opencursor(vsquery_total, mensajes);
         RETURN vrefcursor;
      ELSE
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN e_error_controlat THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         IF vparam = 'Parámetro - Proceso' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9001139,
                                                               pac_iax_common.f_get_cxtidioma));
         -- Bug 21116 - APD - 09/02/2012 - el cobrador bancario es obligatorio
         ELSIF vparam = 'Parámetro - Cobban' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(120081,
                                                               pac_iax_common.f_get_cxtidioma));
         -- fin Bug 21116 - APD - 09/02/2012
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9001140,
                                                               pac_iax_common.f_get_cxtidioma));
         END IF;

         RETURN vrefcursor;
      WHEN e_param_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpasexec, vpar);
         RETURN vrefcursor;
      WHEN e_object_error THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpasexec, vpar);
         RETURN NULL;
      WHEN OTHERS THEN
         IF vrefcursor%ISOPEN THEN
            CLOSE vrefcursor;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpasexec, vpar, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_domiciliacion;

   /*******************************************************************************
   FUNCION F_SET_PRODDOMIS
   Función que inserta los productos seleccionados para realizar la domiciliación en el proceso.
    Parámetros:
     Pcempres  NUMBER : Id. empresa
     Psproces  NUMBER : ID.
     Psproduc  NUMBER : Id. producto
     Pseleccio NUMBER : Valor seleccionado
    Salida :
     Mensajes  T_IAX_MENSAJES

    Retorna: un NUMBER con el id de error.
   ********************************************************************************/
   FUNCTION f_set_proddomis(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobj           VARCHAR2(900) := 'PAC_MD_PRENOTIFICACIONES.F_SET_PRODDOMIS';
      vpar           VARCHAR2(900)
         := NULL || ' pcempres=' || pcempres || ' psproces=' || psproces || ' psproduc='
            || psproduc || ' pseleccio=' || pseleccio;
      vnumerr        NUMBER;
   BEGIN
      IF pcempres IS NULL
         OR psproces IS NULL
         OR psproduc IS NULL
         OR pseleccio IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Esta función llamará a la función pac_dincartera.f_insert_tmp_carteraux.
      vnumerr := pac_prenotificaciones.f_insert_tmp_domisaux(pcempres, psproces, psproduc,
                                                             pseleccio);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);   -- error interno.
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpasexec, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpasexec, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpasexec, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_proddomis;

   FUNCTION f_domrecibos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pruta OUT VARCHAR2,
      pfcobro IN DATE DEFAULT NULL,
      vtimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobj           VARCHAR2(900) := 'PAC_MD_PRENOTIFICACIONES.F_DOMRECIBOS';
      vpar           VARCHAR2(900)
         := NULL || ' pcempres=' || pcempres || ' psproces=' || psproces || ' pruta=' || pruta
            || ' pfcobro=' || pfcobro;
      vnumerr        NUMBER;
      vctipemp       empresas.ctipemp%TYPE;
      vcempres       empresas.cempres%TYPE;
      vobimp         ob_iax_impresion := ob_iax_impresion();
   BEGIN
      IF (pcempres IS NOT NULL) THEN
         BEGIN
            SELECT ctipemp
              INTO vctipemp
              FROM empresas
             WHERE cempres = pcempres;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 100501;   --Empresa inexistente
            WHEN OTHERS THEN
               RETURN 103290;   --Error al leer en la tabla EMPRESAS;
         END;
      ELSE
         BEGIN
            vpasexec := 2;

            SELECT DISTINCT (cempres)
                       INTO vcempres
                       FROM notificaciones
                      WHERE sproces = psproces;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, vobj, vpasexec, 'Empresa inexistente',
                           SQLERRM || ' ' || SQLCODE);
               RETURN 100501;   --Empresa inexistente
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpasexec,
                           'Error al leer en la tabla notificaciones',
                           SQLERRM || ' ' || SQLCODE);
               RETURN 112318;   --Error al leer en la tabla notificaciones;
         END;

         BEGIN
            vpasexec := 3;

            SELECT ctipemp
              INTO vctipemp
              FROM empresas
             WHERE cempres = vcempres;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, vobj, vpasexec, 'Empresa inexistente',
                           SQLERRM || ' ' || SQLCODE);
               RETURN 100501;   --Empresa inexistente
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, vpasexec,
                           'Error al leer en la tabla EMPRESAS', SQLERRM || ' ' || SQLCODE);
               RETURN 103290;   --Error al leer en la tabla EMPRESAS;
         END;
      END IF;

      vnumerr := pac_prenotificaciones.f_domrecibos(vctipemp, pac_iax_common.f_get_cxtidioma,
                                                    psproces, pruta);

      IF (vnumerr = 0) THEN
         vtimp := t_iax_impresion();
         vtimp.EXTEND;
         vobimp.fichero := pruta;
         vtimp(vtimp.LAST) := vobimp;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000006, vpasexec, vpar);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000005, vpasexec, vpar);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobj, 1000001, vpasexec, vpar,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_domrecibos;
END pac_md_prenotificaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PRENOTIFICACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRENOTIFICACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRENOTIFICACIONES" TO "PROGRAMADORESCSI";
