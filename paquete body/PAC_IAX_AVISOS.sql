--------------------------------------------------------
--  DDL for Package Body PAC_IAX_AVISOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_AVISOS" AS
/******************************************************************************
   NOMBRE:      pac_iax_avisos
   PROP¿¿SITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/06/2011   XPL               1. Creaci¿¿n del package.18712: LCOL000 - Analisis de bloque de avisos en siniestros

******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

/*
      Funci¿ que transformar el clob d'entrada a una colecci¿ d'objecte ob_iax_info
       pparams IN clob                   par¿metres que enviem desde la pantalla,
                                        format : SSEGURO#123123;NRIESGO#1;
      mensajes OUT  t_iax_mensajes       Mensajes
      return t_iax_info
      XPL#16072011#18712: LCOL000 - Analisis de bloque de avisos en siniestros
*/
   FUNCTION f_convertir_varchar_coleccion(pparams IN CLOB, mensajes OUT t_iax_mensajes)
      RETURN t_iax_info IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AVISOS.f_convertir_varchar_coleccion';
      vparam         VARCHAR2(1000) := 'par¿metros - pparams :';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtinfo         t_iax_info := t_iax_info();
      tipo           CLOB;
      nombre_columna CLOB;
      valor_columna  CLOB;
      vinfo          ob_iax_info;
      pos            NUMBER;
      posdp          NUMBER;
      posvalor       NUMBER;
   BEGIN
      vtinfo := t_iax_info();

      FOR i IN 1 .. LENGTH(pparams) LOOP
         pos := INSTR(pparams, '#', 1, i);
         posdp := INSTR(pparams, '#', 1, i + 1);
         tipo := SUBSTR(pparams, NVL(pos, 0) + 1,(posdp - NVL(pos, 0)) - 1);
         posvalor := INSTR(tipo, ';', 1, 1);
         nombre_columna := SUBSTR(tipo, 1, posvalor - 1);
         valor_columna := SUBSTR(tipo, posvalor + 1);

         IF valor_columna IS NOT NULL THEN
            vinfo := ob_iax_info();
            vtinfo.EXTEND;
            vinfo.nombre_columna := nombre_columna;
            vinfo.valor_columna := valor_columna;
            vtinfo(vtinfo.LAST) := vinfo;
         END IF;
      END LOOP;

      RETURN vtinfo;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_convertir_varchar_coleccion;

/*
      Funci¿ que retornar¿ tots els avisos a mostrar per pantalla
      pcform IN VARCHAR2                pantalla
      pcmodo IN VARCHAR2                mode
      pcramo IN NUMBER                  ram
      psproduc IN NUMBER                codi producte
      pparams IN clob                   par¿metres que enviem desde la pantalla,
                                        format : SSEGURO#123123;NRIESGO#1;
      plstavisos OUT t_iax_aviso        missatges de sortida
      mensajes OUT  t_iax_mensajes       Mensajes
      return 1/0
      XPL#16072011#18712: LCOL000 - Analisis de bloque de avisos en siniestros
*/
   FUNCTION f_get_avisos(
      pcform IN VARCHAR2,
      pcmodo IN VARCHAR2,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pparams IN CLOB,
      plstavisos OUT t_iax_aviso,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AVISOS.f_get_avisos';
      vparam         VARCHAR2(1000)
         := 'par¿metros - ' || 'pcform:' || pcform || ' pcmodo: ' || pcmodo || ' pcramo: '
            || pcramo || ' psproduc: ' || psproduc;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
      vparams        t_iax_info;
   BEGIN
      --Convertim el clob d'entrada a un t_iax_info
      vparams := f_convertir_varchar_coleccion(pparams, mensajes);
      --Anem a buscar els avisos
      vpasexec := 2;
      vnumerr := pac_md_avisos.f_get_avisos(pcform, pcmodo, pcramo, psproduc, vparams,
                                            plstavisos, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_avisos;
      /*************************************************************************
    Pago duplicado, existe otro pago para el destinatario en el reclamo
    param in pnsinies     : N¿mero de siniestro
    param in pctipdes     : c¿digo de tipo de destinatario
    param in psperson     : identificador de la persona
    param in pcconpag     : c¿digo del concepto de pago
    param in pcidioma     : c¿digo de idioma
         return             : 0 grabaci¿n correcta
                           <> 0 grabaci¿n incorrecta
   *************************************************************************/
      FUNCTION f_aviso_pago_tercero(pnsinies  IN VARCHAR2,
                                    pctipdes  IN NUMBER,
                                    psperson  IN NUMBER,
                                    pcconpag  IN NUMBER,
                                    pcidioma  IN NUMBER,
                                    ptmensaje OUT VARCHAR2) RETURN NUMBER IS

         v_sproduc NUMBER;
         param     NUMBER;
         v_persona VARCHAR2(2000);
         v_pago    NUMBER;
         dup_pago EXCEPTION;

      begin
         IF pctipdes <> 1
         THEN
            RETURN 0;

         ELSE
            SELECT sproduc
              INTO v_sproduc
              FROM sin_siniestro sin,
                   seguros       seg
             WHERE sin.sseguro = seg.sseguro
               and sin.nsinies = pnsinies;
            param := NVL(pac_parametros.f_parproducto_n(v_sproduc,
                                                        'SIN_VALPAGDUPTERCERO'),
                         0);
            IF param = 0 THEN
               return 0;
            ELSE

            BEGIN
               SELECT nnumide
                 INTO v_persona
                 FROM per_personas
                where sperson = psperson;
            exception when others then
            p_control_error ('AP',8,'error_v_persona2 ' || v_persona);
              null;
            end;
              FOR reg in (SELECT pag.nsinies
                 INTO v_pago
                 FROM sin_siniestro    sin,
                      sin_tramita_pago pag,
                      seguros          seg,
                      per_personas     per
                WHERE sin.nsinies = pag.nsinies
                  AND sin.sseguro = seg.sseguro
                  AND pag.sperson = per.sperson
                  AND per.nnumide = v_persona
                  AND pag.cconpag = pcconpag
                  and sin.nsinies <> pnsinies
                  AND seg.sproduc = v_sproduc) LOOP
               RAISE dup_pago;
               --
               END LOOP;
            END IF;

         end if;
      EXCEPTION
         WHEN dup_pago THEN
            ptmensaje := f_axis_literales(9909858 || v_pago,
                                          pac_md_common.f_get_cxtidioma());
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            return 1; -- Pago duplicado, existe otro pago para el destinatario en el reclamo:

         WHEN OTHERS THEN
            ptmensaje := SQLCODE || ' - ' || SQLERRM ||
                         dbms_utility.format_error_backtrace;
            RETURN 1;

      end f_aviso_pago_tercero;
END pac_iax_avisos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AVISOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AVISOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AVISOS" TO "PROGRAMADORESCSI";
