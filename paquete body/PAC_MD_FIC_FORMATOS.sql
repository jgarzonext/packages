--------------------------------------------------------
--  DDL for Package Body PAC_MD_FIC_FORMATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_FIC_FORMATOS" AS
/******************************************************************************
   NOMBRE:       PAC_MD_FIC_FORMATOS
   PROPÓSITO: Nuevo paquete de la capa MD que tendrá las funciones para la gestión de formatos del gestor de informes.
              Controlar todos posibles errores con PAC_IOBJ_MNSAJES.P_TRATARMENSAJE


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/06/2009   JMG                1. Creación del package.
******************************************************************************/

   /*************************************************************************
      Función que ejecuta los formatos de un gestor
      del modelo del parámetro
      param in  pcempres : código empresa
      param in  ptgestor : fecha de contabilidad inicial
      param in ptformat  : mensajes de error
      param in  panio : código empresa
      param in  pmes : fecha de contabilidad inicial
      param in  pmes_dia  : mensajes de error
      param in  pchk_genera : código empresa
      param in  pchkescribe : fecha de contabilidad inicial
      param in out mensajes  : mensajes de error
   *************************************************************************/
   FUNCTION f_genera_formatos(
      pcempres IN NUMBER,
      ptgestor IN VARCHAR2,
      ptformat IN VARCHAR2,
      panio IN NUMBER,
      pmes IN VARCHAR2,
      pmes_dia IN VARCHAR2,
      pchk_genera IN VARCHAR2,
      pchkescribe VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'pcempres=' || pcempres || ', ptgestor=' || ptgestor || ', ptformat=' || ptformat
            || ', panio=' || panio || ', pmes=' || pmes || ', pmes_dia=' || pmes_dia
            || ', pchk_genera=' || pchk_genera || ', pchkescribe=' || pchkescribe;
      vparam_proc    VARCHAR2(3000)
         := f_axis_literales(101606, pac_iax_common.f_get_cxtidioma) || ' =' || panio || ', '
            || f_axis_literales(9000495, pac_iax_common.f_get_cxtidioma) || ' =' || pmes
            || ', ' || f_axis_literales(9900972, pac_iax_common.f_get_cxtidioma) || ' ='
            || pmes_dia || ', ' || f_axis_literales(9000497, pac_iax_common.f_get_cxtidioma)
            || ' ' || f_axis_literales(9001754, pac_iax_common.f_get_cxtidioma) || ' ='
            || pchk_genera || ', '
            || f_axis_literales(9000497, pac_iax_common.f_get_cxtidioma) || ' '
            || f_axis_literales(9905788, pac_iax_common.f_get_cxtidioma) || ' ='
            || pchkescribe || ', ';
      vobject        VARCHAR2(200) := 'PAC_IAX_FIC_FORMATOS.f_genera_formatos';
      vnum_err       NUMBER(1) := 0;
      vcempres       NUMBER;
      variables      VARCHAR2(4000);
      vproces        VARCHAR2(100);
      vtexto         VARCHAR2(200);
      vidioma        NUMBER(1);
      vpsproces      NUMBER := 0;
      vtformat       VARCHAR2(200);
      v_fecha        DATE;
      v_numproces    NUMBER;
   BEGIN
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      BEGIN
         vparam := 'Parametro - Fecha';

         SELECT TO_DATE(LPAD(DECODE(NVL(pmes_dia, '1'), '0', '1', NVL(pmes_dia, '1')), 2, '0')
                        || LPAD(DECODE(NVL(pmes, '1'), '0', '1', NVL(pmes, '1')), 2, '0')
                        || panio,
                        'ddmmyyyy')
           INTO v_fecha
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_error_controlat;
      END;

      IF pchk_genera IS NULL
         AND pchkescribe IS NULL THEN
         vparam := 'Parametro - Check';
         RAISE e_error_controlat;
      END IF;

      vpasexec := 2;

      -- validar que no existan 2 jobs
      SELECT COUNT(1)
        INTO vnum_err
        FROM user_jobs
       WHERE UPPER(what) LIKE 'P_EJECUTAR_FIC_FORMATOS%';

      IF vnum_err > 0 THEN
         -- Ya existe un proceso de fic_formatos activo
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905979);
         RAISE e_object_error;
      END IF;

      vnum_err := pac_fic_procesos.F_GET_NUMFICPROCESOS(vcempres, ptgestor, ptformat,
                                                     panio, pmes, pmes_dia,v_numproces);

      IF vnum_err > 0 OR v_numproces > 0 THEN
         -- Ya existe un proceso de fic_formatos activo
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905979);
         RAISE e_object_error;
      END IF;

      vnum_err := pac_fic_procesos.f_alta_procesoini(f_user, vcempres, ptgestor, ptformat,
                                                     panio, pmes, pmes_dia,
                                                     'PAC_MD_FIC_FORMATOS', vparam_proc,
                                                     vpsproces);
      vpasexec := 6;
      variables := 'P_EJECUTAR_FIC_FORMATOS(' || vcempres || ',''' || ptgestor || ''','''
                   || ptformat || ''',' || ' ' || panio || ',' || ' ''' || pmes || ''','
                   || ' ''' || pmes_dia || ''',' || ' ''' || pchk_genera || ''',' || ' '''
                   || pchkescribe || ''',' || vpsproces || ');';
      vnum_err := pac_jobs.f_ejecuta_job(NULL, variables, NULL);

      IF vnum_err > 0 THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ' men=' || vnum_err);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, vnum_err);
         RETURN 1;
      ELSE
         vidioma := pac_md_common.f_get_cxtidioma;
         vtexto := pac_iobj_mensajes.f_get_descmensaje(9001242, vidioma) || vpsproces;   --'Proceso generado : '
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9001242, vtexto);
      END IF;

      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1000005;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1000006;
      WHEN e_error_controlat THEN
         IF vparam = 'Parametro - Fecha' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9905943,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 9905943;
         END IF;

         IF vparam = 'Parametro - Check' THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                             (mensajes, 1, 0,
                                              f_axis_literales(9902561,
                                                               pac_iax_common.f_get_cxtidioma));
            RETURN 9902561;
         END IF;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1000001;
   END f_genera_formatos;
END pac_md_fic_formatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_FIC_FORMATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FIC_FORMATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_FIC_FORMATOS" TO "PROGRAMADORESCSI";
