--------------------------------------------------------
--  DDL for Package Body PAC_MD_CODIGOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CODIGOS" AS
/******************************************************************************
   NOMBRE:      pac_md_codigos
   PROPóSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/02/2012   XPL               1. Creación del package.1
*****************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   FUNCTION f_get_idiomas_activos(
      pcuridiomas OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcont          NUMBER;
      vquery         VARCHAR2(2000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_CODIGOS.f_get_idiomas_activos';
      vparam         VARCHAR2(1000) := 'f=';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_codigos.f_get_idiomas_activos(pac_md_common.f_get_cxtempresa,
                                                   pac_md_common.f_get_cxtidioma, vquery);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      pcuridiomas := pac_iax_listvalores.f_opencursor(vquery, mensajes);
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
   END f_get_idiomas_activos;

   FUNCTION f_get_tipcodigos(pcurtipcodigos OUT sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcont          NUMBER;
      vquery         VARCHAR2(2000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_CODIGOS.f_get_tipcodigos';
      vparam         VARCHAR2(1000) := 'f=';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_codigos.f_get_tipcodigos(pac_md_common.f_get_cxtempresa,
                                              pac_md_common.f_get_cxtidioma, vquery);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      pcurtipcodigos := pac_iax_listvalores.f_opencursor(vquery, mensajes);
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
   END f_get_tipcodigos;

   FUNCTION ff_get_valor(
      pnombre_columna IN VARCHAR2,
      ptinfo IN t_iax_info,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vcont          NUMBER;
   BEGIN
      FOR j IN ptinfo.FIRST .. ptinfo.LAST LOOP
         IF UPPER(ptinfo(j).nombre_columna) = UPPER(pnombre_columna) THEN
            --SÓLO OBTENDREMOS PARAMETROS QUE EL LISTENER ESPERE
            RETURN ptinfo(j).valor_columna;
         END IF;
      END LOOP;

      RETURN NULL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END ff_get_valor;

/*


*/
   FUNCTION f_get_codigos(
      ptinfo IN t_iax_info,
      pcodigo OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_MD_CODIGOS.f_get_codigos';
      vparam         VARCHAR2(1000) := 'xml=';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(3000);
      vparams        t_iax_info;
      vmensaje       CLOB;
      valor          VARCHAR2(100);
      vparser        xmlparser.parser;
      vurl           VARCHAR2(200);
      vntimeout      NUMBER;
      v_domdoc       xmldom.domdocument;
      vcodigo        VARCHAR2(1000);
      vcont          NUMBER;
      vidrequest     VARCHAR2(200);
      vttipcod       VARCHAR2(2000);
   BEGIN
      IF ptinfo IS NOT NULL
         AND ptinfo.COUNT > 0 THEN
         vmensaje :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ia="http://www.csi_ti.com/ia/">
            <soapenv:Header/>
            <soapenv:Body>
               <ia:mntProductRq>';

         FOR i IN ptinfo.FIRST .. ptinfo.LAST LOOP
            IF ptinfo(i).nombre_columna = 'idRequest' THEN
               vidrequest := ff_get_valor(ptinfo(i).nombre_columna, ptinfo, mensajes);
            END IF;
         END LOOP;

         FOR i IN (SELECT   *
                       FROM cfg_param_codigos
                      WHERE UPPER(ctipcod) = UPPER(vidrequest)
                        AND cempres = pac_md_common.f_get_cxtempresa
                   ORDER BY norden ASC) LOOP
            FOR j IN ptinfo.FIRST .. ptinfo.LAST LOOP
               IF (UPPER(i.tparam) = UPPER(ptinfo(j).nombre_columna)) THEN
                  valor := ff_get_valor(ptinfo(j).nombre_columna, ptinfo, mensajes);

                  IF valor IS NOT NULL THEN
                     IF ptinfo(j).nombre_columna = 'idRequest' THEN
                        vmensaje := vmensaje || '   <' || ptinfo(j).nombre_columna || '>'
                                    || valor || '</' || ptinfo(j).nombre_columna || '>';
                     ELSE
                        vmensaje := vmensaje || '   <' || LOWER(ptinfo(j).nombre_columna)
                                    || '>' || valor || '</' || LOWER(ptinfo(j).nombre_columna)
                                    || '>';
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;

         vmensaje :=
            vmensaje
            || ' </ia:mntProductRq>
            </soapenv:Body>
         </soapenv:Envelope>';

         SELECT url, ntimeout
           INTO vurl, vntimeout
           FROM int_hostb2b
          WHERE empresa = pac_md_common.f_get_cxtempresa
            AND cinterf = 'I999';

         pac_xml.peticion_host_codigos(vurl, vntimeout, vmensaje, vparser);
         vpasexec := 390;
         v_domdoc := xmlparser.getdocument(vparser);
         vcodigo := pac_xml.buscarnodotexto(v_domdoc, 'codigo');

         IF vcodigo = 'UNDEFINED'
            OR vcodigo IS NULL
            OR vcodigo = ''
            OR vcodigo = 'null' THEN
            vcodigo := pac_xml.buscarnodotexto(v_domdoc, 'descripcionEstado');
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1, vcodigo);
            RAISE e_object_error;
         ELSE
            pcodigo := vcodigo;

            SELECT ttipcod
              INTO vttipcod
              FROM cfg_cod_codigos
             WHERE cempres = pac_md_common.f_get_cxtempresa
               AND ctipcod = vidrequest
               AND cidioma = pac_md_common.f_get_cxtidioma;

            vcodigo := vttipcod || ' : ' || vcodigo;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1, vcodigo);
         END IF;
      END IF;

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
   END f_get_codigos;

   FUNCTION f_set_codsproduc(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_CODIGOS.f_set_codsproduc';
      vparam         VARCHAR2(1000)
         := 'pcramo=' || pcramo || ',pcmodali:' || pcmodali || ',pccolect:' || pccolect
            || ',pctipseg:' || pctipseg;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      vcempres       NUMBER := pcempres;
      vcidioma       NUMBER := pcidioma;
   BEGIN
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      IF pcidioma IS NULL THEN
         vcidioma := pac_md_common.f_get_cxtidioma;
      END IF;

      vnumerr := pac_codigos.f_set_codsproduc(vcempres, vcidioma, pcramo, pcmodali, pccolect,
                                              pctipseg, pcodigo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_set_codsproduc;

   FUNCTION f_set_codcgarant(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_CODIGOS.f_set_codcgarant';
      vparam         VARCHAR2(1000) := 'pcempres=' || pcempres || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      vcempres       NUMBER := pcempres;
      vcidioma       NUMBER := pcidioma;
   BEGIN
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      IF pcidioma IS NULL THEN
         vcidioma := pac_md_common.f_get_cxtidioma;
      END IF;

      vnumerr := pac_codigos.f_set_codcgarant(vcempres, vcidioma, pcodigo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_set_codcgarant;

   FUNCTION f_set_codpregun(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_CODIGOS.f_set_codpregun';
      vparam         VARCHAR2(1000) := 'pcempres=' || pcempres || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      vcempres       NUMBER := pcempres;
      vcidioma       NUMBER := pcidioma;
   BEGIN
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      IF pcidioma IS NULL THEN
         vcidioma := pac_md_common.f_get_cxtidioma;
      END IF;

      vnumerr := pac_codigos.f_set_codpregun(vcempres, vcidioma, pcodigo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_set_codpregun;

   FUNCTION f_set_codramo(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_CODIGOS.f_set_codramo';
      vparam         VARCHAR2(1000) := 'pcempres=' || pcempres || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      vcempres       NUMBER := pcempres;
      vcidioma       NUMBER := pcidioma;
   BEGIN
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      IF pcidioma IS NULL THEN
         vcidioma := pac_md_common.f_get_cxtidioma;
      END IF;

      vnumerr := pac_codigos.f_set_codramo(vcempres, vcidioma, pcodigo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_set_codramo;

   FUNCTION f_set_codactivi(
      pcramo IN NUMBER,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_CODIGOS.f_set_codactivi';
      vparam         VARCHAR2(1000)
                := 'pcramo:' || pcramo || ',pcempres=' || pcempres || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      vcempres       NUMBER := pcempres;
      vcidioma       NUMBER := pcidioma;
   BEGIN
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      IF pcidioma IS NULL THEN
         vcidioma := pac_md_common.f_get_cxtidioma;
      END IF;

      vnumerr := pac_codigos.f_set_codactivi(pcramo, vcempres, vcidioma, pcodigo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_set_codactivi;

   FUNCTION f_set_codliterales(
      ptlitera_1 IN VARCHAR2,
      ptlitera_2 IN VARCHAR2,
      ptlitera_3 IN VARCHAR2,
      ptlitera_4 IN VARCHAR2,
      ptlitera_5 IN VARCHAR2,
      ptlitera_6 IN VARCHAR2,
      ptlitera_7 IN VARCHAR2,
      ptlitera_8 IN VARCHAR2,
      ptlitera_9 IN VARCHAR2,
      ptlitera_10 IN VARCHAR2,
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pcodigo OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_CODIGOS.f_set_codliterales';
      vparam         VARCHAR2(1000) := 'pcempres=' || pcempres || ',pcidioma:' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER := 0;
      vcempres       NUMBER := pcempres;
      vcidioma       NUMBER := pcidioma;
   BEGIN
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      IF pcidioma IS NULL THEN
         vcidioma := pac_md_common.f_get_cxtidioma;
      END IF;

      vnumerr := pac_codigos.f_set_codliterales(ptlitera_1, ptlitera_2, ptlitera_3, ptlitera_4,
                                                ptlitera_5, ptlitera_6, ptlitera_7, ptlitera_8,
                                                ptlitera_9, ptlitera_10, vcempres, vcidioma,
                                                pcodigo);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
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
   END f_set_codliterales;
END pac_md_codigos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CODIGOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CODIGOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CODIGOS" TO "PROGRAMADORESCSI";
