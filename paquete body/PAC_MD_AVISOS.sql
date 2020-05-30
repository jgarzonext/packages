--------------------------------------------------------
--  DDL for Package Body PAC_MD_AVISOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_AVISOS" AS
/******************************************************************************
   NOMBRE:      pac_md_avisos
   PROPÃ“SITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/06/2011   XPL               1. Creación del package.18712: LCOL000 - Analisis de bloque de avisos en siniestros
   2.0        19/10/2011   RSC               2. 0019412: LCOL_T004: Completar parametrización los productos de Vida Individual
   3.0        11/11/2011   JMF               3. 0019412 LCOL_T004 Completar parametrización de los productos de Vida Individual
   4.0        19/12/2011   RSC               4. 0020595: LCOL - UAT - TEC - Errors tarificant i aportacions
   5.0        04/01/2012   RSC               5. 0020671: LCOL_T001-LCOL - UAT - TEC: Contratación
   6.0        09/01/2012   DRA               6. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
   7.0        26/06/2012   DRA               7. 0021927: MDP - TEC - Parametrización producto de Hogar (MHG) - Nueva producción
******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

/*
      Funció que et buscar un valor a la llista que hem enviat desde la pantalla passant-li un nom de columna
       pnombre_columna IN VARCHAR2      Nom de la columna a cercar
      ptinfo IN t_iax_info              Llista de paràmetres d'entrada
      mensajes IN OUT t_iax_mensajes    Mensajes
      XPL#16072011#18712: LCOL000 - Analisis de bloque de avisos en siniestros
*/
   FUNCTION ff_get_valor(
      pnombre_columna IN VARCHAR2,
      ptinfo IN t_iax_info,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
   BEGIN
      FOR j IN ptinfo.FIRST .. ptinfo.LAST LOOP
         IF UPPER('p' || ptinfo(j).nombre_columna) = UPPER(pnombre_columna) THEN
            RETURN ptinfo(j).valor_columna;
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_get_valor;

/*
      Funció que retornarà tots els avisos a mostrar per pantalla
      pcform IN VARCHAR2                pantalla
      pcmodo IN VARCHAR2                mode
      pcramo IN NUMBER                  ram
      psproduc IN NUMBER                codi producte
      pparams IN t_iax_info             parametres que enviem desde la pantalla
      plstavisos OUT t_iax_aviso        missatges de sortida
      mensajes IN OUT t_iax_mensajes    Mensajes
      XPL#16072011#18712: LCOL000 - Analisis de bloque de avisos en siniestros
*/
   FUNCTION f_get_avisos(
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pparams IN t_iax_info,
      plstavisos OUT t_iax_aviso,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_AVISOS.f_get_avisos';
      vparam         VARCHAR2(1000)
                  := 'f=' || pcform || ' m=' || pcmodo || ' r=' || pcramo || ' p=' || psproduc;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
      vparams        t_iax_info;
      vcform         VARCHAR2(50);
      vcmodo         VARCHAR2(50);
      vcramo         NUMBER;
      vsproduc       NUMBER;
      vccfgavis      VARCHAR2(100);
      vcaviso        NUMBER;
      vtaviso        VARCHAR2(200);
      vctipaviso     NUMBER;
      vttipavis      VARCHAR2(200);
      vtfunc         VARCHAR2(200);
      vcolumna       VARCHAR2(100);
      v_tipocolumna  VARCHAR2(100);
      npos           NUMBER;
      vfunc          VARCHAR2(200);
      vpaquete       VARCHAR2(200);
      v_param2       VARCHAR2(2000);
      vvalor         VARCHAR2(200);
      v_paramout     VARCHAR2(2000);
      vlstavisos     sys_refcursor;
      obaviso        ob_iax_aviso;
      vcbloqueo      NUMBER;
      v_coma         VARCHAR(10);
      -- Bug 20671 - RSC - 09/01/2012 - LCOL_T001-LCOL - UAT - TEC: Contratación
      vvalor_entero  NUMBER;
      vvalor_decimal NUMBER;
      -- Fin Bug 20671
      v_params_adic  VARCHAR2(250);
      vtipo          NUMBER;
   BEGIN
      --de moment utilitzem el mateix perfil de pantalles pels avisos
      vpasexec := 100;
      vccfgavis := pac_md_cfg.f_get_user_cfgform(pac_md_common.f_get_cxtusuario,
                                                 pac_md_common.f_get_cxtempresa, pcform,
                                                 mensajes);

      IF vccfgavis IS NULL THEN
         RAISE e_object_error;
      END IF;

      --Query que retornarà els avisos que podem veure
      vpasexec := 110;
      vvalor := ff_get_valor('PMENSWARNINFO', pparams, mensajes);
      vnumerr := pac_avisos.f_get_avisos(pac_md_common.f_get_cxtempresa, pcform, pcmodo,
                                         vccfgavis, pcramo, psproduc,
                                         pac_md_common.f_get_cxtidioma, vvalor, vsquery);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 120;
      vlstavisos := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      vpasexec := 130;
      plstavisos := t_iax_aviso();
      --Recorrarem els avisos per fer les validacions amb la funció que li pertoca
      vpasexec := 140;

      LOOP
         vpasexec := 150;

         FETCH vlstavisos
          INTO vcaviso, vtaviso, vctipaviso, vttipavis, vtfunc, vcbloqueo;

         EXIT WHEN vlstavisos%NOTFOUND;
         vpasexec := 160;

         IF vtfunc IS NOT NULL THEN
            vpasexec := 161;

            -- BUG21927:DRA:26/06/2012:Inici
            IF INSTR(vtfunc, '(') <> 0
               AND INSTR(vtfunc, ')') <> 0 THEN
               -- Si tiene parametros adicionales los añadiremos al final
               v_params_adic := SUBSTR(vtfunc, INSTR(vtfunc, '(') + 1,
                                       INSTR(vtfunc, ')') - INSTR(vtfunc, '(') - 1);
               vtfunc := SUBSTR(vtfunc, 1, INSTR(vtfunc, '(') - 1);
            ELSE
               v_params_adic := NULL;
            END IF;

            -- BUG21927:DRA:26/06/2012:Fi
            vpasexec := 163;
            npos := INSTR(vtfunc, '.', 1);
            vpasexec := 170;
            vfunc := UPPER(SUBSTR(vtfunc, npos + 1));
            vpasexec := 180;
            vpaquete := UPPER(SUBSTR(vtfunc, 0, npos - 1));

            IF vfunc IS NOT NULL
               AND vpaquete IS NOT NULL THEN
               --crearem dinàmicament la crida al paquest i funció per validar l'avís
               vpasexec := 190;
               vquery := 'begin :v_param := ' || vpaquete || '.' || vfunc || '(';
               --Amb el loop mirarem els parametres d'entrada que es necessita.
               --Tota funció de validació ha de tenir almenys un parametre out (tmensaje varchar2)
               --i ens retornarà 0(ok),1(error),2 (informatiu,warning)
               vpasexec := 200;

               FOR i IN
                  (SELECT   argument_name, data_type, POSITION
                       FROM user_arguments
                      WHERE object_id = (SELECT object_id
                                           FROM user_objects
                                          WHERE object_name = vpaquete
                                            AND object_type = 'PACKAGE')
                        AND object_name = vfunc
                        AND in_out = 'IN'
                        AND LOWER(argument_name) NOT LIKE 'parfix_%'   -- BUG21927:DRA:26/06/2012
                   ORDER BY POSITION ASC) LOOP
                  vpasexec := 210;

                  IF i.argument_name IS NOT NULL THEN
                     --Obtindrem el valor de la columna de la funció
                     --El paràmetre que enviem desde la pantalla ha de ser igual al nom
                     -- de la columna de la funció però sense la p de davant, per ex: li enviariem
                     --SSEGURO i no PSSEGURO(tal com estar a la funció)
                     vpasexec := 220;
                     vvalor := ff_get_valor(i.argument_name, pparams, mensajes);
                     -- ini Bug 0018967 - 30/09/2011 - JMF
                     -- Bug 0019412 - 11/11/2011 - JMF
                     vpasexec := 230;

                     IF i.POSITION = 1 THEN
                        v_coma := NULL;
                     ELSE
                        v_coma := ' , ';
                     END IF;

                     IF vvalor IS NULL THEN
                        vpasexec := 240;
                        vquery := vquery || v_coma || 'null';
                     ELSIF i.data_type = 'DATE' THEN
                        vpasexec := 250;
                        vquery := vquery || v_coma || ' TO_DATE(''' || vvalor
                                  || ''', ''dd/mm/yyyy'')';
                     ELSIF i.data_type = 'NUMBER' THEN
                        vpasexec := 260;

                        -- Bug 20671 - RSC - 09/01/2012 - LCOL_T001-LCOL - UAT - TEC: Contratación
                        IF NVL
                              (pac_parametros.f_parempresa_t
                                                            (pac_md_common.f_get_cxtempresa(),
                                                             'SISTEMA_NUMERICO_BD'),
                               ',.') = '.,' THEN
                           vvalor_entero := REPLACE(pac_util.splitt(vvalor, 1, ','), '.', '');
                           vvalor_decimal := pac_util.splitt(vvalor, 2, ',');

                           IF vvalor_decimal IS NOT NULL THEN
                              vvalor := vvalor_entero || '.' || vvalor_decimal;
                           ELSE
                              vvalor := vvalor_entero;
                           END IF;
                        ELSIF NVL
                                (pac_parametros.f_parempresa_t
                                                             (pac_md_common.f_get_cxtempresa(),
                                                              'SISTEMA_NUMERICO_BD'),
                                 ',.') = ',.' THEN
                           --
                           vvalor_entero := REPLACE(pac_util.splitt(vvalor, 1, '.'), ',', '');
                           vvalor_decimal := pac_util.splitt(vvalor, 2, '.');

                           IF vvalor_decimal IS NOT NULL THEN
                              vvalor := vvalor_entero || '.' || vvalor_decimal;
                           ELSE
                              vvalor := vvalor_entero;
                           END IF;
                        --
                        ELSE
                           IF NVL
                                 (pac_parametros.f_parempresa_t
                                                            (pac_md_common.f_get_cxtempresa(),
                                                             'MONEDA_CONF_INST'),
                                  'EUR') = 'EUR' THEN
                              vvalor := REPLACE(vvalor, ',', '');
                           ELSE
                              vvalor := REPLACE(vvalor, '.', '');
                           END IF;
                        END IF;

                        -- Fin Bug 20671

                        -- Bug 20595
                        vpasexec := 265;
                        vquery := vquery || v_coma || CHR(39) || vvalor || CHR(39);
                     ELSE
                        vpasexec := 270;
                        vquery := vquery || v_coma || CHR(39)
                                  || REPLACE(vvalor, CHR(39), CHR(39) || CHR(39)) || CHR(39);
                     END IF;
                  -- fin Bug 0018967 - 30/09/2011 - JMF
                  END IF;

                  vpasexec := 280;
                  vvalor := '';
               END LOOP;

               vpasexec := 290;

               -- BUG21927:DRA:26/06/2012:Inici
               IF v_params_adic IS NOT NULL THEN
                  vquery := vquery || ' , ' || v_params_adic;
               END IF;

               -- BUG21927:DRA:26/06/2012:Fi
               vpasexec := 291;
               vquery := vquery || ' , :tmensaje); end;';

               BEGIN
                  vpasexec := 300;

                  EXECUTE IMMEDIATE vquery
                              USING OUT v_param2, OUT v_paramout;
               EXCEPTION
                  WHEN OTHERS THEN
                     -- Bug 0019412 - 11/11/2011 - JMF
                     p_tab_error(f_sysdate, f_user, vobjectname, vpasexec,
                                 SUBSTR(SQLERRM, 1, 500), SUBSTR(vquery, 1, 2500));
                     v_param2 := 1;
                     v_paramout := f_axis_literales(101901, pac_md_common.f_get_cxtidioma);
               END;

               --Si el que ens retorna la funció és un error o un warning el mostrarem
               --al multiregistre d'avisos
               IF v_param2 <> 0 THEN
                  vpasexec := 310;
                  obaviso := ob_iax_aviso();
                  vpasexec := 320;
                  obaviso.caviso := vcaviso;
                  obaviso.taviso := vtaviso;
                  vpasexec := 330;
                  obaviso.ctipaviso := vctipaviso;
                  obaviso.ttipaviso := vttipavis;
                  vpasexec := 340;
                  obaviso.tfunc := vtfunc;
                  obaviso.cactivo := 1;
                  vpasexec := 350;
                  obaviso.cbloqueo := vcbloqueo;
                  obaviso.tmensaje := v_paramout;
                  vpasexec := 360;
                  obaviso.tbloqueo := ff_desvalorfijo(800034, pac_md_common.f_get_cxtidioma,
                                                      v_param2);
                  vpasexec := 370;
                  plstavisos.EXTEND;
                  plstavisos(plstavisos.LAST) := obaviso;
                  vpasexec := 380;
                  obaviso := ob_iax_aviso();

                  --En el cas que sigui un error acumlarem el missatge en
                  --els missatges d'error de la pantalla
                  IF v_param2 = 1
                     AND vcbloqueo = 1 THEN
                     vnumerr := v_param2;
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL, v_paramout);
                  ELSIF v_param2 =
                            1   -- en cas que el bloqueig sigui warning mostrarem missatge warning
                        AND vcbloqueo = 2 THEN
                     --vnumerr := 0;
                     IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                          'NUEVO_TIPO_WARNING'),
                            0) = 1 THEN
                        vtipo := 3;
                     ELSE
                        vtipo := 2;
                     END IF;

                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, vtipo, NULL, v_paramout);
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 390;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     SQLCODE || '-' || SQLERRM);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_avisos;
END pac_md_avisos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AVISOS" TO "PROGRAMADORESCSI";
