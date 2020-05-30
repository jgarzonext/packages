--------------------------------------------------------
--  DDL for Package Body PAC_MD_TRANSFERENCIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_TRANSFERENCIAS" AS
/******************************************************************************
   NOMBRE:       pac_md_transferencias
   PROPÓSITO:  Gestión de las transferencias

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/06/2009   XPL                1. Creación del package.
   2.0        04/02/2010   DRA                2. 0012913: CRE200 - Mejoras en Transferencias
   3.0        11/05/2010   DRA                3. 0014344: APRA - Incorporar a transferencias los pagos de liquidación de comisiones
   4.0        19/112/2014  RDD                4. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
   5.0        14/01/2016   MDS                5. 0039238/0223588: Liquidación de comisiones según nivel de red comercial (bug hermano interno)
   6.0        03/02/2016   MDS                6. 0040304: Error al regenerar listados de transferencias (bug hermano interno)
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/***********************************************************************
      Limpia de la tabla remesas_previo los registros de un usuario
      param out mensajes : mensajes de error
      return             : 0 OK, 1 Error
   ***********************************************************************/
   FUNCTION f_limpia_remesasprevio(mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_limpia_remesasprevio';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_transferencias.f_limpia_remesasprevio();

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_limpia_remesasprevio;

/***********************************************************************
      Función que nos dice si tenemos registros pendientes de gestionar por un usuario(f_user)
      en el caso que haya registros para gestionar devolveremos en el param phayregistros un 1,
      en el caso contrario phayregistros =  0
      param out mensajes : mensajes de error
      param out hayregistros : 0 no hay registros, N num. registros
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_registros_pendientes(phayregistros OUT NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_registros_pendientes';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_transferencias.f_registros_pendientes(phayregistros);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_registros_pendientes;

/***********************************************************************
      Función que nos dice si tenemos registros en las tablas que ya esten intentando transferir
      otros usuarios, en este caso devolveremos una notificación y no dejaremos seguir. Ya que los registros
      ya estaran siendo modificados.
      param in  ptipobusqueda : varchar2, tots els tipus que hem marcat per fer la cerca
      param in out mensajes : mensajes de error
      param out hayregistros : 0 no hay registros, 1 hay registros
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_registros_duplicados(
      ptipobusqueda IN VARCHAR2,
      phayregistros IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_registros_duplicados';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_transferencias.f_registros_duplicados(ptipobusqueda, phayregistros);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_registros_duplicados;

    /***********************************************************************
      Función que nos inserta en la tabla remesas_previo los registros que estamos buscando.
      param in  pcempres
      param in  pcidioma IN NUMBER,
      param in  psremisesion IN NUMBER,   -- Identificador de la sesion de inserciones de la remesa
      param in  ptipproceso IN VARCHAR2,   --1- Rentas 2- recibos 3- siniestros 4-Reembolsos
      param in  pcramo IN NUMBER,
      param in  psproduc IN NUMBER,
      param in  pfabono IN DATE,
      param in  pftransini IN DATE,
      param in  pftransfin IN DATE,
      param in  pctransferidos IN NUMBER,
      param in  pprestacion IN NUMBER DEFAULT 0,
      param in  pagrup IN NUMBER DEFAULT NULL,   --Agrupación
      param in  pcausasin IN NUMBER DEFAULT NULL   --En el caso de siniestros, la causa del siniestro
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_insert_remesas_previo(
      pcempres IN NUMBER,
      pagrupacion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfabonoini IN DATE,
      pfabonofin IN DATE,
      pftransini IN DATE,
      pftransfin IN DATE,
      pctransferidos IN NUMBER,
      pnremesa IN NUMBER,
      ptipproceso IN VARCHAR2,
      piimportt IN NUMBER,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_insert_remesas_previo';
      vparam         VARCHAR2(4000)
         := 'parámetros - pcempres : ' || pcempres || ', pagrupacion :' || pagrupacion
            || ', pcramo : ' || pcramo || ', psproduc: ' || psproduc || ', pfabonoini : '
            || pfabonoini || ', pfabonofin : ' || pfabonofin || ', piimportt : ' || piimportt
            || ', psperson : ' || psperson;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsprocesoslin  NUMBER;
   BEGIN
      vnumerr := pac_transferencias.f_insert_remesas_previo(pcempres,
                                                            pac_md_common.f_get_cxtidioma,
                                                            pagrupacion, pcramo, psproduc,
                                                            pfabonoini, pfabonofin,
                                                            pftransini, pftransfin,
                                                            pctransferidos, pnremesa,
                                                            ptipproceso, piimportt, psperson,
                                                            vsprocesoslin);

      IF vnumerr = -1 THEN
         -- Si hi han errors per UK vol dir que algun ja els està tractant
         IF vsprocesoslin IS NOT NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 2, NULL,
                                             f_axis_literales(9900957,
                                                              pac_md_common.f_get_cxtidioma)
                                             || ' '
                                             || f_axis_literales
                                                                (9900724,
                                                                 pac_md_common.f_get_cxtidioma)
                                             || ' : ' || vsprocesoslin);
            COMMIT;
            RETURN 2;
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje
                                              (mensajes, 2, NULL,
                                               f_axis_literales(9900957,
                                                                pac_md_common.f_get_cxtidioma));
            COMMIT;
            RETURN 2;
         END IF;
      ELSIF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      IF vsprocesoslin IS NOT NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 2, NULL,
                                             f_axis_literales(9900724,
                                                              pac_md_common.f_get_cxtidioma)
                                             || ' : ' || vsprocesoslin);
         COMMIT;
         RETURN 2;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_insert_remesas_previo;

    /***********************************************************************
      Función que nos devuelve los registros de la tabla remesas_previo por usuario
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_transferencias(
      pcempres IN NUMBER,
      pagrupacion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfabonoini IN DATE,
      pfabonofin IN DATE,
      pftransini IN DATE,
      pftransfin IN DATE,
      pctransferidos IN NUMBER,
      pctipobusqueda IN VARCHAR2,
      pnremesa IN NUMBER,
      pccc IN VARCHAR2,
      pcurtransferencias OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_get_transferencias';
      vparam         VARCHAR2(4000) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(8000);   --rdd
   BEGIN
      vnumerr := pac_transferencias.f_get_transferencias(pcempres, pagrupacion, pcramo,
                                                         psproduc, pfabonoini, pfabonofin,
                                                         pftransini, pftransfin,
                                                         pctransferidos, pctipobusqueda,
                                                         pnremesa, pccc,
                                                         pac_md_common.f_get_cxtidioma,
                                                         vsquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pcurtransferencias := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_transferencias;

   /***********************************************************************
      Función que nos actualiza la tabla, si le pasamos un sremesa actualiza solo
      el registro con marcado, si no le pasamos el sremesa se marcan o desmarcan todos
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_actualiza_remesas_previo(
      psremesa IN NUMBER,
      pcmarcado IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_actualiza_remesas_previo';
      vparam         VARCHAR2(4000) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(4000);
   BEGIN
      vnumerr := pac_transferencias.f_actualiza_remesas_previo(psremesa, pcmarcado);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_actualiza_remesas_previo;

    /***********************************************************************
      Función que nos devuelve el total de los registros marcados en remesas_previo
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_total(
      pnremesa IN NUMBER,
      pccc IN VARCHAR2,
      ptotal OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_get_total';
      vparam         VARCHAR2(4000) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_transferencias.f_get_total(pnremesa, pccc, ptotal);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_total;

    /***********************************************************************
      Función que nos devuelve las descripciones de los bancos
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_cuentas(
      pnremesa IN NUMBER,
      pccc IN VARCHAR2,
      pcurbancos OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_get_total';
      vparam         VARCHAR2(4000) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(4000);
   BEGIN
      vnumerr := pac_transferencias.f_get_cuentas(pnremesa, pccc, vquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pcurbancos := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_cuentas;

    /***********************************************************************
      Función que nos transfiere y nos graba los datos de remesas a remesas_previo
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_transferir(
      pcempres IN NUMBER,
      pfabono IN DATE,   -- BUG12913:DRA:04/02/2010
      pnremesa OUT NUMBER,
      params_out OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_transferir';
      vparam         VARCHAR2(4000)
                            := 'parámetros - pcempres=' || pcempres || ', pfabono=' || pfabono;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(2000);
      params_in      VARCHAR2(100);
      v_nomfitx      VARCHAR2(100);
   BEGIN
      vnumerr := pac_transferencias.f_transferir(pcempres, pfabono,   -- BUG12913:DRA:04/02/2010
                                                 pnremesa);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSE
         -- JMF - 20/05/2015 si es sepa, ya se genera fichero xml en pac_transferencias.f_transferir
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'TRANSF_IBAN_XML'), 0) = 0 THEN
            vnumerr := pac_transferencias.f_generar_fichero(pnremesa, pfabono);   -- BUG12913:DRA:04/02/2010

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;

         -- Ini Bug 0039238/0223588 - MDS - 14/01/2016
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'TRANSF_IBAN_XML'), 0) = 1 THEN
            vnumerr := pac_transferencias.f_generacion_ficheros_sepa(pnremesa, pfabono);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;
      -- Fin Bug 0039238/0223588 - MDS - 14/01/2016
      END IF;

      params_in := pac_md_common.f_get_cxtidioma || '|' || TO_CHAR(f_sysdate, 'YYYYMMDD')
                   || '|' || TO_CHAR(f_sysdate, 'YYYYMMDD') || '|'
                   || TO_CHAR(pfabono, 'YYYYMMDD') || '|' || TO_CHAR(pfabono, 'YYYYMMDD')
                   || '|' || pnremesa   -- BUG12913:DRA:22/03/2010
                                     || '|' || pac_md_common.f_get_cxtempresa;   -- BUG14344:DRA:11/05/2010
      -- BUG12913:DRA:08/02/2010:Inici
      -- params_out := pac_md_map.f_ejecuta(354, params_in, mensajes);
      v_nomfitx := pac_map.f_get_nomfichero(354);
      v_nomfitx := SUBSTR(v_nomfitx, INSTR(v_nomfitx, '\', -1) + 1);
      v_nomfitx := REPLACE(v_nomfitx, '.csv',
                           '_' || TO_CHAR(f_sysdate, 'DDMMYYYY') || '_'
                           || TO_CHAR(f_sysdate, 'HH24MISS') || '.csv');
      vnumerr := pac_map.f_extraccion(354, params_in, v_nomfitx, params_out);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      -- BUG12913:DRA:08/02/2010:Fi
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL,
                                           f_axis_literales(9001873,
                                                            pac_md_common.f_get_cxtidioma)
                                           || ' ' || pnremesa);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_transferir;

    /***********************************************************************
      Función que nos genera un fichero y nos devuelve la ruta y nombre del fichero
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_generar_fichero(
      pnremesa IN NUMBER,
      pfabono IN DATE,   -- BUG12913:DRA:04/02/2010
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_generacion_fichero';
      vparam         VARCHAR2(4000)
                            := 'parámetros - pnremesa=' || pnremesa || ', pfabono=' || pfabono;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(2000);
      -- JMF 20/05/2015 generar fichero xml
      v_emp          remesas.cempres%TYPE;
      v_ccc          remesas.ccc%TYPE;
      vidremesasepa  remesas_sepa.idremesassepa%TYPE;
      w_nomfichero   ficherosremesa.nfichero%TYPE;
      vcontrem       ficherosremesa.nmovimi%TYPE;
   BEGIN
      SELECT MAX(cempres), MAX(ccc)
        INTO v_emp, v_ccc
        FROM remesas
       WHERE nremesa = pnremesa
         AND sremesa = (SELECT MAX(sremesa)
                          FROM remesas
                         WHERE nremesa = pnremesa);

      IF NVL(pac_parametros.f_parempresa_n(v_emp, 'TRANSF_IBAN_XML'), 0) = 1 THEN
/* Bug 0040304/0225326 - MDS - 03/02/2016
         vidremesasepa := pac_transferencias.f_set_remesas_sepa(NULL, pnremesa, pfabono);
         vnumerr := pac_sepa.f_genera_xml_transferencias(vidremesasepa);
         w_nomfichero := pac_nombres_ficheros.f_nom_transf(pnremesa, v_ccc);

         --
         -- pac_transferencias,p_insert_ficherosremesa(pnremesa, 1, REPLACE(w_nomfichero, 'TXT', 'XML'), v_ccc);
         --
         SELECT NVL(MAX(nmovimi), 0) + 1
           INTO vcontrem
           FROM ficherosremesa
          WHERE nremesa = pnremesa;

         BEGIN
            INSERT INTO ficherosremesa
                        (nremesa, nmovimi, nfichero, ncuenta)
                 VALUES (pnremesa, vcontrem, w_nomfichero, v_ccc);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;   -- Si ya existe pues nada (no pasará nunca)
         END;

         --
         --
         --
         vnumerr := pac_sepa.f_genera_fichero_dom_trans('T', vidremesasepa,
                                                        SUBSTR(w_nomfichero, 1,
                                                               INSTR(w_nomfichero, '.', -1) - 1));
*/

         -- Ini Bug 0040304/0225326 - MDS - 03/02/2016
         vnumerr := pac_transferencias.f_generacion_ficheros_sepa(pnremesa, pfabono);

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnumerr);
            RAISE e_object_error;
         END IF;
      -- Fin Bug 0040304/0225326 - MDS - 03/02/2016
      ELSE
         vnumerr := pac_transferencias.f_generar_fichero(pnremesa, pfabono);   -- BUG12913:DRA:04/02/2010

         IF vnumerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_generar_fichero;

   -- BUG12913:DRA:04/02/2010:Inici
   /*************************************************************************
         Función que valida que la fecha de abono para las transferencias sea correcta
         param in fabono    : fecha de abono
         param out mensajes : mensajes de error
         return             : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_fabono(pfabono IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      verrnum        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'pfabono = ' || pfabono;
      vobject        VARCHAR2(2000) := 'PAC_MD_TRANSFERENCIAS.f_valida_fabono';
      v_terror       VARCHAR2(2000);
   BEGIN
      IF pfabono IS NULL THEN
         RAISE e_param_error;
      END IF;

      verrnum := pac_transferencias.f_valida_fabono(pfabono, v_terror);

      IF verrnum <> 0 THEN
         IF v_terror IS NOT NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verrnum, v_terror);
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verrnum);
         END IF;

         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_fabono;

   -- BUG12913:DRA:04/02/2010:Fi

   -- BUG12913:DRA:08/02/2010:Inici
   -- Bug 0032079 - JMF - 15/07/2014
   /***********************************************************************
      Función que genera de nuevo el fichero excel
      pprevio             : 1 = Listado previo, resto valores listado normal
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_generar_fichero_excel(
      params_out OUT VARCHAR2,
      mensajes OUT t_iax_mensajes,
      pprevio IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_generar_fichero_excel';
      vparam         VARCHAR2(4000) := 'parámetros - null';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      params_in      VARCHAR2(100);
      v_nomfitx      VARCHAR2(100);
   BEGIN
      vnumerr := pac_transferencias.f_generar_fichero_excel(params_out, pprevio);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_generar_fichero_excel;

   -- BUG12913:DRA:08/02/2010:Fi

   -- BUG12913:DRA:22/03/2010:Inici
   /***********************************************************************
      Función que retorna el numero de dias de fecha de abono
      param in cempres   : codigo de empresa
      param out pnumdias : numero de dias
      param out mensajes : mensajes de error
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_dias_abono(
      pcempres IN NUMBER,
      pnumdias OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_get_dias_abono';
      vparam         VARCHAR2(4000) := 'parámetros - pcempres: ' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_transferencias.f_get_dias_abono(pcempres, pnumdias);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_dias_abono;

-- BUG12913:DRA:22/03/2010:Fi

   -- BUG14344:DRA:17/05/2010:Inici
   /***********************************************************************
      Función que el texto a mostrar en la columna de origen

      param in ptipproceso IN VARCHAR2,   --1- Rentas 2- recibos 3- siniestros 4-Reembolsos
      param out tliteral   OUT VARCHAR2
   ***********************************************************************/
   FUNCTION f_get_desc_concepto(
      ptipproceso IN VARCHAR2,
      ptlitera OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_get_desc_concepto';
      vparam         VARCHAR2(4000) := 'parámetros - ptipproceso: ' || ptipproceso;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_transferencias.f_get_desc_concepto(ptipproceso,
                                                        pac_md_common.f_get_cxtidioma,
                                                        ptlitera);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_desc_concepto;

-- BUG14344:DRA:17/05/2010:Fi

   /***********************************************************************
      --BUG19522 - JTS - 28/10/2011
      Función que nos devuelve los registros agrupados
      de la tabla remesas_previo por usuario
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_get_transferencias_agrup(
      pcempres IN NUMBER,
      pagrupacion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfabonoini IN DATE,
      pfabonofin IN DATE,
      pftransini IN DATE,
      pftransfin IN DATE,
      pctransferidos IN NUMBER,
      pctipobusqueda IN VARCHAR2,
      pnremesa IN NUMBER,
      pcurtransferencias OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_get_transferencias_agrup';
      vparam         VARCHAR2(4000) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(4000);
   BEGIN
      vnumerr := pac_transferencias.f_get_transferencias_agrup(pcempres, pagrupacion, pcramo,
                                                               psproduc, pfabonoini,
                                                               pfabonofin, pftransini,
                                                               pftransfin, pctransferidos,
                                                               pctipobusqueda, pnremesa,
                                                               pac_md_common.f_get_cxtidioma,
                                                               vsquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pcurtransferencias := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_transferencias_agrup;

   /***********************************************************************
      --BUG19522 - JTS - 10/11/2011
      Función que actualiza la fecha de cambio
      return             : 0 OK , 1 error
   ***********************************************************************/
   FUNCTION f_set_fcambio(psremesa IN NUMBER, pfcambio IN DATE, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_set_fcambio';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_transferencias.f_set_fcambio(psremesa, pfcambio);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_fcambio;

   FUNCTION f_get_trans_retenida(
      pcagente IN NUMBER,
      pcurtransferencias OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_get_trans_retenida';
      vparam         VARCHAR2(4000) := 'parámetros - pcagente: ' || pcagente;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vsquery        VARCHAR2(4000);
   BEGIN
      vnumerr := pac_transferencias.f_get_trans_retenida(pcagente, vsquery);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      pcurtransferencias := pac_iax_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_trans_retenida;

   FUNCTION f_trans_ret_cancela(psclave IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_trans_ret_cancela';
      vparam         VARCHAR2(500) := 'parámetros - psclave: ' || psclave;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_transferencias.f_trans_ret_cancela(psclave);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_trans_ret_cancela;

   FUNCTION f_trans_ret_desbloquea(psclave IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_transferencias.f_trans_ret_desbloquea';
      vparam         VARCHAR2(500) := 'parámetros - psclave: ' || psclave;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_transferencias.f_trans_ret_desbloquea(psclave);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_trans_ret_desbloquea;
END pac_md_transferencias;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_TRANSFERENCIAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRANSFERENCIAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRANSFERENCIAS" TO "PROGRAMADORESCSI";
