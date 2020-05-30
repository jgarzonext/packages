--------------------------------------------------------
--  DDL for Package Body PAC_IAX_INSPECCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_INSPECCION" AS
/******************************************************************************
 NOMBRE: pac_iax_INSPECCION
   PROPÓSITO:  Funciones para la inspeccion

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/04/2013   XPL              1. Creación del package.
   2.0        11/07/2013   JDS              2. 0025221: LCOL_T031-LCOL - Fase 3 - Desarrollo Inspección de Riesgo
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_set_documentacion_inspeccion(
      pcempres IN NUMBER,
      ptfichero IN VARCHAR2,
      pidinspeccion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500) := ' --';
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_inspeccion.f_set_documentacion_inspeccion';
      vsorden_out    NUMBER;
      vsordenext_out NUMBER;
      vninspeccion_out NUMBER;
   BEGIN
      vnumerr := pac_md_inspeccion.f_buscar_inspeccion(pcempres, NULL, pidinspeccion,
                                                       vsorden_out, vsordenext_out,
                                                       vninspeccion_out, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vnumerr := pac_md_inspeccion.f_set_documentacion_inspeccion(pcempres, ptfichero,
                                                                  vsorden_out, pidinspeccion,
                                                                  vninspeccion_out, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_documentacion_inspeccion;

   FUNCTION f_set_accesorios_inspeccion(
      pcempres IN NUMBER,
      pidinspeccion IN VARCHAR2,
      pasegurableinspeccion IN NUMBER,
      pactualizaciondatos IN NUMBER,
      ptipo IN VARCHAR2,
      ptmarca IN VARCHAR2,
      ptreferencia IN VARCHAR2,
      pvalorunitario IN NUMBER,
      pcantidad IN NUMBER,
      poriginal IN NUMBER,
      pasegurable IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := ' pidinspeccion :' || pidinspeccion || ',ptipo:' || ptipo || ',ptmarca:'
            || ptmarca || ',ptreferencia:' || ptreferencia || ',pvalorunitario:'
            || pvalorunitario || ',pcantidad:' || pcantidad || ',poriginal:' || poriginal
            || ',pasegurable:' || pasegurable;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_inspeccion.f_set_accesorios_inspeccion';
      vsorden_out    NUMBER;
      vsordenext_out NUMBER;
      vninspeccion_out NUMBER;
      vninspeccion_outx NUMBER;
      vsorden        NUMBER;
      vctipacc       NUMBER;
   BEGIN
      vnumerr := pac_md_inspeccion.f_act_orden_ext(pcempres, vsorden, pidinspeccion, NULL,
                                                   NULL, NULL, NULL, NULL, NULL, mensajes);
      --  IF pactualizaciondatos = 1 THEN
      vnumerr := pac_md_inspeccion.f_buscar_inspeccion(pcempres, vsorden, NULL, vsorden_out,
                                                       vsordenext_out, vninspeccion_out,
                                                       mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --  END IF;
      IF poriginal = 1 THEN
         vctipacc := 4;
      ELSIF poriginal = 0 THEN
         vctipacc := 3;
      END IF;

      vnumerr := pac_iax_inspeccion.f_set_inspeccion_acc(pcempres, vsorden, vninspeccion_out,
                                                         ptipo, vctipacc,
                                                         ptmarca || ' ' || ptreferencia,
                                                         pvalorunitario * pcantidad,
                                                         pasegurable, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vnumerr := pac_md_inspeccion.f_act_accesorios(pcempres, vsorden, vninspeccion_out,
                                                    mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_accesorios_inspeccion;

   FUNCTION f_carga_inspeccion_auto_seguro(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
                                := ' psorden :' || psorden || ',pninspeccion:' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_inspeccion.f_carga_inspeccion_auto_seguro';
      vsorden_out    NUMBER;
      vsordenext_out NUMBER;
      vninspeccion_out NUMBER;
      vninspeccion_outx NUMBER;
      vsorden        NUMBER;
      vctipacc       NUMBER;
   BEGIN
      vnumerr := pac_md_inspeccion.f_act_seguros(pcempres, psorden, pninspeccion, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_carga_inspeccion_auto_seguro;

   FUNCTION f_set_vehiculo_inspeccion(
      pcempres IN NUMBER,
      pidinspeccion IN VARCHAR2,
      pasegurableinspeccion IN NUMBER,
      pactualizaciondatos IN NUMBER,
      pcapacidad IN NUMBER,
      pcchasis IN VARCHAR2,
      pclase IN VARCHAR2,
      pclindraje IN VARCHAR2,
      pcmarca IN VARCHAR2,
      pmodelo IN NUMBER,
      pmotor IN VARCHAR2,
      ppaismatricula IN VARCHAR2,
      ppassajeros IN VARCHAR2,
      pservicio IN VARCHAR2,
      ptipo IN VARCHAR2,
      ptipoplaca IN VARCHAR2,
      pplaca IN VARCHAR2,
      pvin IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := ' pidinspeccion :' || pidinspeccion || ',pasegurableinspeccion:'
            || pasegurableinspeccion || ',pactualizaciondatos:' || pactualizaciondatos
            || ',pcchasis:' || pcchasis || ',pclase:' || pclase || ',pclindraje:'
            || pclindraje || ',pcmarca:' || pcmarca || ',pmodelo:' || pmodelo || ',pmotor:'
            || pmotor || ',pservicio:' || pservicio || ',ptipo:' || ptipo || ',ptipoplaca:'
            || ptipoplaca || ',pplaca:' || pplaca || ',pvin:' || pvin;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_iax_inspeccion.f_set_vehiculo_inspeccion';
      vsorden        NUMBER;
      vctipmat       NUMBER;
      vsorden_out    NUMBER;
      vsordenext_out NUMBER;
      vninspeccion_out NUMBER;
      vninspeccion_outx NUMBER;
      vtpais         NUMBER;
   BEGIN
      vpasexec := 2;

      --equivalencias
      IF ptipoplaca = 'C' THEN
         vctipmat := 12;
      ELSIF ptipoplaca = 'L' THEN
         vctipmat := 11;
      ELSIF ptipoplaca IS NOT NULL THEN
         vctipmat := 15;   --por defecto un tipo de matricula temporal temporal
      END IF;

      vpasexec := 3;
      vnumerr := pac_md_inspeccion.f_act_orden_ext(pcempres, vsorden, pidinspeccion, 3,
                                                   vctipmat, pplaca, pmotor, pcchasis, pvin,
                                                   mensajes);
      vpasexec := 4;

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF pactualizaciondatos = 1 THEN
         vnumerr := pac_md_inspeccion.f_buscar_inspeccion(pcempres, vsorden, NULL,
                                                          vsorden_out, vsordenext_out,
                                                          vninspeccion_out, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 5;
      vnumerr := pac_iax_inspeccion.f_set_inspeccion(pcempres, vsorden, vninspeccion_out,
                                                     f_sysdate, 3, pasegurableinspeccion, 0,
                                                     NULL, NULL, NULL, 0, 0, vninspeccion_outx,
                                                     mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 66;

      IF ppaismatricula IS NOT NULL THEN
         BEGIN
--buscar pais origen matricula--ppaismatricula
            SELECT cpais
              INTO vtpais
              FROM despaises
             WHERE UPPER(tpais) LIKE UPPER(ppaismatricula) || '%'
               AND cidioma = pac_md_common.f_get_cxtidioma
               AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vtpais := NULL;
         END;
      END IF;

      vpasexec := 7;
      vnumerr := pac_iax_inspeccion.f_set_inspeccion_dveh(pcempres, vsorden, vninspeccion_outx,
                                                          LPAD(pcmarca, 3, '0')
                                                          || LPAD(pclase, 2, '0')
                                                          || LPAD(ptipo, 3, '0'),
                                                          vtpais, pcapacidad, pclindraje,
                                                          pmodelo, ppassajeros, pservicio,
                                                          NULL, NULL, NULL, NULL, NULL, NULL,
                                                          NULL, NULL, pmotor, NULL, NULL, NULL,
                                                          NULL, NULL, pactualizaciondatos,
                                                          mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --actualizamos seguro
      vnumerr := pac_iax_inspeccion.f_carga_inspeccion_auto_seguro(pcempres, vsorden,
                                                                   vninspeccion_outx, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 8;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_vehiculo_inspeccion;

   FUNCTION f_set_inspeccion_acc(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcaccesorio IN NUMBER,
      pctipacc IN NUMBER,
      ptdesacc IN VARCHAR2,
      pivalacc IN NUMBER,
      pcasegurable IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ',psorden:' || psorden || ',pninspeccion:' || pninspeccion || ',pcaccesorio:'
            || pcaccesorio || ',pctipacc:' || pctipacc || ',ptdesacc:' || ptdesacc
            || ',pivalacc:' || pivalacc || ',pcasegurable:' || pcasegurable;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.f_set_inspeccion_acc';
      vsproduc       NUMBER;
   BEGIN
      vnumerr := pac_md_inspeccion.f_set_inspeccion_acc(pcempres, psorden, pninspeccion,
                                                        pcaccesorio, pctipacc, ptdesacc,
                                                        pivalacc, pcasegurable, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_inspeccion_acc;

   FUNCTION f_set_inspeccion_doc(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcdocume IN NUMBER,
      pcgenerado IN NUMBER,
      pcobliga IN NUMBER,
      pcadjuntado IN NUMBER,
      piddocgedox IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := ',psorden:' || psorden || ',pninspeccion:' || pninspeccion || ',PCDOCUME:'
            || pcdocume || ',PCGENERADO:' || pcgenerado || ',PCOBLIGA:' || pcobliga
            || ',PCADJUNTADO:' || pcadjuntado || ',PIDDOCGEDOX:' || piddocgedox;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_inspeccion.f_set_inspeccion_doc';
      vsproduc       NUMBER;
   BEGIN
      vnumerr := pac_md_inspeccion.f_set_inspeccion_doc(pcempres, psorden, pninspeccion,
                                                        pcdocume, pcgenerado, pcobliga,
                                                        pcadjuntado, piddocgedox, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_inspeccion_doc;

   FUNCTION f_set_inspeccion_dveh(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pcversion IN VARCHAR2,
      pcpaisorigen IN VARCHAR2,
      pnpma IN NUMBER,
      pccilindraje IN VARCHAR2,
      panyo IN NUMBER,
      pnplazas IN NUMBER,
      pcservicio IN NUMBER,
      pcblindado IN NUMBER,
      pccampero IN NUMBER,
      pcgama IN NUMBER,
      pcmatcabina IN VARCHAR2,
      pivehinue IN NUMBER,
      pcuso IN VARCHAR2,
      pccolor IN NUMBER,
      pnkilometraje IN NUMBER,
      pctipmotor IN VARCHAR2,
      pntara IN NUMBER,
      pcpintura IN NUMBER,
      pccaja IN NUMBER,
      pctransporte IN NUMBER,
      pctipcarroceria IN NUMBER,
      pesactualizacion IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := 'psorden:' || psorden || ',pninspeccion:' || pninspeccion || ',pcversion:'
            || pcversion || ',pcpaisorigen:' || pcpaisorigen || ',pnpma:' || pnpma
            || ',pccilindraje:' || pccilindraje || ',panyo:' || panyo || ',pnplazas:'
            || pnplazas || ',pcservicio:' || pcservicio || ',pcblindado:' || pcblindado
            || ',pccampero:' || pccampero || ',pcgama:' || pcgama || ',pcmatcabina:'
            || pcmatcabina || ',pivehinue:' || pivehinue || ',pcuso:' || pcuso || ',pccolor:'
            || pccolor || ',pnkilometraje:' || pnkilometraje || ',pctipmotor:' || pctipmotor
            || ',pntara:' || pntara || ',pcpintura:' || pcpintura || ',pctransporte:'
            || pctransporte || ',pctipcarroceria:' || pctipcarroceria || ',pesactualizacion:'
            || pesactualizacion;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.f_set_inspeccion_dveh';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vsseguro       NUMBER;
   BEGIN
      vnumerr := pac_md_inspeccion.f_set_inspeccion_dveh(pcempres, psorden, pninspeccion,
                                                         pcversion, pcpaisorigen, pnpma,
                                                         pccilindraje, panyo, pnplazas,
                                                         pcservicio, pcblindado, pccampero,
                                                         pcgama, pcmatcabina, pivehinue,
                                                         pcuso, pccolor, pnkilometraje,
                                                         pctipmotor, pntara, pcpintura,
                                                         pccaja, pctransporte,
                                                         pctipcarroceria, pesactualizacion,
                                                         mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      -- COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_inspeccion_dveh;

   FUNCTION f_set_inspeccion(
      pcempres IN NUMBER,
      psorden IN NUMBER,
      pninspeccion_in IN NUMBER,
      pfinspeccion IN DATE,
      pcestado IN NUMBER,
      pcresultado IN NUMBER,
      pcreinspeccion IN NUMBER,
      phllegada IN VARCHAR2,
      phsalida IN VARCHAR2,
      pccentroinsp IN NUMBER,
      pcinspdomi IN NUMBER,
      pcpista IN NUMBER,
      pninspeccion_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(2500)
         := 'psorden:' || psorden || ',pninspeccion_in:' || pninspeccion_in || ',pcestado:'
            || pcestado || ',pcresultado:' || pcresultado || ',pcreinspeccion:'
            || pcreinspeccion || ',phllegada:' || phllegada || ',phsalida:' || phsalida
            || ',pccentroinsp:' || pccentroinsp || ',pcinspdomi:' || pcinspdomi || ',pcpista:'
            || pcpista;
      vpasexec       NUMBER(5) := 1;
      vobject        VARCHAR2(500) := 'pac_md_inspeccion.F_SET_INSPECCION';
      vsorden        NUMBER;
      vcversion      VARCHAR2(11);
      vsseguro       NUMBER;
   BEGIN
      vnumerr := pac_md_inspeccion.f_set_inspeccion(pcempres, psorden, pninspeccion_in,
                                                    pfinspeccion, pcestado, pcresultado,
                                                    pcreinspeccion, phllegada, phsalida,
                                                    pccentroinsp, pcinspdomi, pcpista,
                                                    pninspeccion_out, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      --COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_inspeccion;

   FUNCTION f_necesita_inspeccion(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_necesita_inspeccion';
      vparam         VARCHAR2(1000)
                 := 'parámetros - pparams : psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      RETURN 0;   --pac_md_inspeccion.f_necesita_inspeccion(psseguro, ptablas, MENSAJES);
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
   END f_necesita_inspeccion;

   FUNCTION f_get_ord_inspec_mod_consulta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pnecesitainspeccion OUT NUMBER,
      presultadoinspeccion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_get_ord_inspec_mod_consulta';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_inspeccion.f_get_ord_inspec_mod_consulta(psseguro, pnmovimi, pnriesgo,
                                                             pnecesitainspeccion,
                                                             presultadoinspeccion, mensajes);
      RETURN cur;
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
   END f_get_ord_inspec_mod_consulta;

   FUNCTION f_get_ordenes_inspeccion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2,
      pnecesitainspeccion OUT NUMBER,
      presultadoinspeccion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo || ',ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_get_ordenes_inspeccion';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_inspeccion.f_get_ordenes_inspeccion(psseguro, pnmovimi, pnriesgo, ptablas,
                                                        pnecesitainspeccion,
                                                        presultadoinspeccion, mensajes);
      RETURN cur;
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
   END f_get_ordenes_inspeccion;

   FUNCTION f_gestion_inspeccion(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2,
      pnecesitainspeccion OUT NUMBER,
      presultadoinspeccion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo || ',ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_gestion_inspeccion';
      cur            sys_refcursor;
   BEGIN
      IF NOT pac_iax_produccion.isaltacol THEN
         cur := pac_md_inspeccion.f_gestion_inspeccion(psseguro, pnmovimi, pnriesgo, ptablas,
                                                       pnecesitainspeccion,
                                                       presultadoinspeccion, mensajes);
      ELSE
         pnecesitainspeccion := 0;
         presultadoinspeccion := 0;
      END IF;

      COMMIT;
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN NULL;
   END f_gestion_inspeccion;

   FUNCTION f_desretener(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo || ',ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_get_ordenes_inspeccion';
      cur            sys_refcursor;
   BEGIN
      IF pac_iax_inspeccion.f_permite_emitirinspeccion(psseguro, ptablas, mensajes) = 0 THEN
         UPDATE seguros
            SET creteni = 0
          WHERE sseguro = psseguro;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_desretener;

   FUNCTION f_permite_emitirinspeccion(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_permite_emitirinspeccion';
      vparam         VARCHAR2(1000)
                 := 'parámetros - pparams : psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_inspeccion.f_permite_emitirinspeccion(psseguro, ptablas, mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RETURN 1;
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
   END f_permite_emitirinspeccion;

/*(SSEGURO, null,
                                                                NMOVIMI, null,
                                                                null, null,
                                                                CAUTREC, null,
                                                                NOCURRE, null,
                                                                null, null,
                                                                null, null,
                                                                null, "POL",
                                                                null);*/
   FUNCTION f_permite_emitirinspec_pend(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_permite_emitirinspec_pend';
      vparam         VARCHAR2(1000)
                 := 'parámetros - pparams : psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_inspeccion.f_permite_emitirinspec_pend(psseguro, ptablas, mensajes);

      IF vnumerr <> 0 THEN
         RETURN 1;
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
   END f_permite_emitirinspec_pend;

   FUNCTION f_autorizar_todo_menos_inspec(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcautrec IN NUMBER,
      pnocurre IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_autorizar_todo_menos_inspec';
      vparam         VARCHAR2(1000)
                 := 'parámetros - pparams : psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsorden        NUMBER;
      vcreteni       NUMBER;
   BEGIN
      --Autorizamos PSU's
      vnumerr := pac_md_psu.f_gestion_control(psseguro, NULL, pnmovimi, NULL, NULL, NULL,
                                              pcautrec, NULL, pnocurre, NULL, NULL, NULL,
                                              NULL, NULL, NULL, ptablas, NULL, NULL, mensajes);

      IF vnumerr = 0 THEN
         UPDATE psu_retenidas
            SET cmotret = 0,
                observ = ff_desvalorfijo(66, pac_md_common.f_get_cxtidioma, 14),   --Autorizada, pdt. inspeccion
                cusuaut = pac_md_common.f_get_cxtusuario,
                ffecaut = f_sysdate
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         --pedimos orden de inspección
         vnumerr := pac_md_inspeccion.f_crear_orden_insp(ptablas, psseguro, NVL(pnmovimi, 1),
                                                         NVL(pnriesgo, 1), vsorden, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

--actualizamos creteni
         /*vnumerr := pac_md_inspeccion.f_gest_retener_porinspeccion(ptablas, psseguro, pnmovimi,
                                                                   pnriesgo, vsorden, vcreteni,
                                                                   mensajes);*/
         IF ptablas = 'POL' THEN
            UPDATE seguros
               SET creteni = 14
             WHERE sseguro = psseguro;
         ELSE
            UPDATE estseguros
               SET creteni = 14
             WHERE sseguro = psseguro;
         END IF;

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_autorizar_todo_menos_inspec;

   FUNCTION f_lanza_solicitud_insp(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_lanza_solicitud_insp';
      vparam         VARCHAR2(2000)
                 := 'parámetros - pparams : psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsorden        NUMBER;
      vcreteni       NUMBER;
      vcsituac       NUMBER;
      vcreteni_b     NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      IF ptablas != 'EST' THEN
         SELECT csituac, creteni
           INTO vcsituac, vcreteni_b
           FROM seguros
          WHERE sseguro = psseguro;
      ELSE
         SELECT csituac, creteni
           INTO vcsituac, vcreteni_b
           FROM estseguros
          WHERE sseguro = psseguro;
      END IF;

      vpasexec := 2;

      IF vcsituac IN(4, 5)
         AND vcreteni_b IN(7, 0) THEN
         vpasexec := 3;
         --pedimos orden de inspección
         vnumerr := pac_md_inspeccion.f_crear_orden_insp(ptablas, psseguro, NVL(pnmovimi, 1),
                                                         NVL(pnriesgo, 1), vsorden, mensajes);
         vpasexec := 4;

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

--actualizamos creteni
         vnumerr := pac_md_inspeccion.f_gest_retener_porinspeccion(ptablas, psseguro, pnmovimi,
                                                                   pnriesgo, 1, 4, vsorden,
                                                                   vcreteni, mensajes);
         vpasexec := 5;

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;

           /*vparampsu := pac_parametros.f_parproducto_n(v_sproduc, 'PSU');

           IF NVL(vparampsu, 0) = 1 THEN*/
         /*  vnumerr := pac_md_psu.f_gestion_control(psseguro, NULL, NULL, NULL, NULL, NULL, 1, NULL,
                                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'POL',
                                                   NULL, mensajes);
           */
               /*
                    IF nerror <> 0 THEN
                       RAISE e_object_error;
                    END IF;
                 END IF;
           */
         COMMIT;
      ELSE
         vpasexec := 6;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1,
                                              f_axis_literales(9901731,
                                                               pac_md_common.f_get_cxtidioma));
         RAISE e_object_error;
      END IF;

      vpasexec := 7;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_lanza_solicitud_insp;

   FUNCTION f_revisar_inspeccion(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_revisar_inspeccion';
      vparam         VARCHAR2(1000)
                 := 'parámetros - pparams : psseguro: ' || psseguro || ' ptablas: ' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsorden        NUMBER;
      vcreteni       NUMBER;
   BEGIN
      IF ptablas = 'POL' THEN
         UPDATE seguros
            SET creteni = 2
          WHERE sseguro = psseguro;
      ELSE
         UPDATE estseguros
            SET creteni = 2
          WHERE sseguro = psseguro;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_revisar_inspeccion;

   FUNCTION f_get_irordenes(
      ptablas IN VARCHAR2,
      pctipmat IN NUMBER,
      pcmatric IN VARCHAR2,
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'pctipmat :' || pctipmat || ', pcmatric : ' || pcmatric || ' pcmatric :'
            || pcmatric || ', pninspeccion : ' || pninspeccion || ', ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_get_ordenes_inspeccion';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_inspeccion.f_get_irordenes(ptablas, pctipmat, pcmatric, psorden,
                                               pninspeccion, pmensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_irordenes;

   FUNCTION f_get_irinspecciones(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
                                := 'psorden :' || psorden || ' pninspeccion :' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_get_irinspecciones';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_inspeccion.f_get_irinspecciones(psorden, pninspeccion, pmensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_irinspecciones;

   FUNCTION f_get_irinspeccionesdveh(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
                                := 'psorden :' || psorden || ' pninspeccion :' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_get_irinspeccionesdveh';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_inspeccion.f_get_irinspeccionesdveh(psorden, pninspeccion, pmensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_irinspeccionesdveh;

   FUNCTION f_get_irinspeccionesacc(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
                                := 'psorden :' || psorden || ' pninspeccion :' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_get_irinspeccionesacc';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_inspeccion.f_get_irinspeccionesacc(psorden, pninspeccion, pmensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_irinspeccionesacc;

   FUNCTION f_get_irinspeccionesdoc(
      psorden IN NUMBER,
      pninspeccion IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
                                := 'psorden :' || psorden || ' pninspeccion :' || pninspeccion;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_get_irinspeccionesdoc';
      cur            sys_refcursor;
   BEGIN
      cur := pac_md_inspeccion.f_get_irinspeccionesdoc(psorden, pninspeccion, pmensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(pmensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
   END f_get_irinspeccionesdoc;

   FUNCTION f_tiene_inspec_vigente(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pctipmat IN VARCHAR2,
      pcmatric IN VARCHAR2,
      psproduc IN NUMBER,
      ptablas IN VARCHAR2,
      pmodo IN VARCHAR2,
      pinspeccion_vigente OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
      vparam         VARCHAR2(500)
         := 'psseguro :' || psseguro || ', pnmovimi : ' || pnmovimi || ',pnriesgo:'
            || pnriesgo || ',ptablas :' || ptablas;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_INSPECCION.f_TIENE_INSPEC_VIGENTE';
      cur            sys_refcursor;
   BEGIN
      vnumerr := pac_md_inspeccion.f_tiene_inspec_vigente(psseguro, pnmovimi, pnriesgo,
                                                          pctipmat, pcmatric, psproduc,
                                                          ptablas, pmodo, pinspeccion_vigente,
                                                          mensajes);
      RETURN vnumerr;
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
   END f_tiene_inspec_vigente;
END pac_iax_inspeccion;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_INSPECCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_INSPECCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_INSPECCION" TO "PROGRAMADORESCSI";
