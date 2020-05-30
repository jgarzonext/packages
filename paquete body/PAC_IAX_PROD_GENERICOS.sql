--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PROD_GENERICOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PROD_GENERICOS" IS
/******************************************************************************
   NOMBRE:       pac_md_prod_genericos
   PROPÓSITO: Funciones para gestionar productos genericos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/08/2010    XPL              1. Creación del package.
   2.0        07/10/2013    HRE              2. Bug 0028462: HRE - Cambio dimension campo sseguro
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
   Obtiene las companias asociadas al seguro especificado
   param in psseguro   : Codigo sseguro
   param out ptcompanias   : Companias
   param out mensajes    : Codi idioma
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_obtener_companias(
      psseguro IN NUMBER,
      ptcompanias OUT t_iax_companiprod,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vidioma        NUMBER;
      cur            sys_refcursor;
      vparam         VARCHAR2(500) := 'parámetros - psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROD_GENERICOS.f_obtener_compañias';
   BEGIN
      tcompanias := t_iax_companiprod();
      vnumerr := pac_md_prod_genericos.f_obtener_companias(psseguro, ptcompanias, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      tcompanias := ptcompanias;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_obtener_companias;

   /*************************************************************************
   Marca el producto correspondiente al seguro especificado
   param in psseguro   : Codigo sseguro
   param in pccompani  : Codigo compania
   param in pmarcar    : Marca
   param in pmodo      : Modo
   param out mensajes  : Mensajes
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_marcar_compania(
      psseguro IN NUMBER,
      pccompani IN NUMBER,
      psproduc IN NUMBER,
      pmarcar IN NUMBER,
      piddoc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro: ' || psseguro || ' - pccompani: ' || pccompani
            || ' - pmarcar: ' || pmarcar;
      vobject        VARCHAR2(200) := 'PAC_MD_PROD_GENERICOS.f_marcar_compañia';
      vnumerr        NUMBER;
   BEGIN
      vsseguro := psseguro;
      vnumerr := pac_md_prod_genericos.f_marcar_compania(psseguro, pccompani, psproduc,
                                                         pmarcar, piddoc, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
   END f_marcar_compania;

   /*************************************************************************
   Pide un presupuesto
   param out mensajes  : Mensajes
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_pedir_presupuesto(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(20) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_PROD_GENERICOS.f_pedir_presupuesto';
   BEGIN
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_pedir_presupuesto;

/*************************************************************************
   Contrata un producto específico
   param out psseguro  : Codigo sseguro
   param out pnpoliza  : Num. poliza
   param out mensajes  : Mensajes
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_contratar_especifico(
      psseguro IN NUMBER,   --seguro de les taules EST, anteriorment ja hem cridat a pac_iax_produccion.f_editarpropuesta
      pccompani IN NUMBER,
      psproduc IN NUMBER,
      psproducesp OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'PSSEGURO : ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_PROD_GENERICOS.f_contratar_especifico';
      onmovimi       NUMBER;
      vnumerr        NUMBER;
      aux_ssegpol    NUMBER;
      vsproduc       NUMBER;
      vcont          NUMBER;
      ppreguntas     t_iax_preguntas;
      pgarantias     t_iax_garantias;
      osseguro       NUMBER;
      v_index        NUMBER;
      ptclausulas    t_iax_clausulas;
   BEGIN
        --recuperamos el producto de la compañía seleccionada
      /*  IF tcompanias IS NOT NULL
           AND tcompanias.COUNT > 0 THEN
           FOR compania IN tcompanias.FIRST .. tcompanias.LAST LOOP
              IF tcompanias(compania).cmarcar = 1 THEN
                 psproducesp := tcompanias(compania).sproducesp;
              END IF;
           END LOOP;
        END IF;*/
      psproducesp := psproduc;

      IF psproducesp IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000413);
         RAISE e_param_error;
      END IF;

      --Después de haber traspasado la póliza original vamos a adaptarla para el producto específico,
      --asignando, eliminando todo lo que sea del producto especifico...
      pac_iax_produccion.vproducto := psproducesp;
      pac_iax_produccion.vempresa := pac_iax_common.f_get_cxtempresa;
      pac_iax_produccion.gidioma := pac_iax_common.f_get_cxtidioma;
      pac_iax_produccion.poliza.det_poliza.sproduc := psproducesp;
      --Vamos a traspasar la información en la capa MD
      vnumerr :=
         pac_md_prod_genericos.f_traspasar_especifico(pac_iax_produccion.poliza.det_poliza,
                                                      mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

--asignamos a las variables globales los valores correctos obtenidos de la anterior función
      pac_iax_produccion.vssegpol := pac_iax_produccion.poliza.det_poliza.ssegpol;
      pac_iax_produccion.vmodalidad := pac_iax_produccion.poliza.det_poliza.cmodali;
      pac_iax_produccion.vccolect := pac_iax_produccion.poliza.det_poliza.ccolect;
      pac_iax_produccion.vcramo := pac_iax_produccion.poliza.det_poliza.cramo;
      pac_iax_produccion.vctipseg := pac_iax_produccion.poliza.det_poliza.ctipseg;
--Inicializamos el paquete pac_iaxpar_productos con los nuevos parametros que hemos obtenido de la anterior función
      vnumerr :=
         pac_iaxpar_productos.f_inicializa(pac_iax_produccion.poliza.det_poliza.sproduc,
                                           pac_iax_produccion.poliza.det_poliza.cmodali,
                                           pac_iax_common.f_get_cxtempresa,
                                           pac_iax_common.f_get_cxtidioma,
                                           pac_iax_produccion.poliza.det_poliza.ccolect,
                                           pac_iax_produccion.poliza.det_poliza.cramo,
                                           pac_iax_produccion.poliza.det_poliza.ctipseg,
                                           mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

--Asignamos la actividad que toca
      vnumerr :=
         pac_iax_produccion.f_set_actividad
                                         (pac_iax_produccion.poliza.det_poliza.gestion.cactivi,
                                          mensajes);   -- lo asigno

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
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
   END f_contratar_especifico;

    /*******************************************************************************
   FUNCION PAC_adm_cobparcial.F_COBRO_DEPOSITO
   Registra en la genda de la propuesta cuando existe un deposito en la poliza

   Parámetros:
     param in pnrecibo  : Número de recibo
     param in pctipcob  : Tipo de cobro (V.F.: 552)
     param in piparcial : Importe del cobro parcial
     param in pcmoneda  : Código de moneda (inicialmente no se tiene en cuenta)
     psolicitud
     return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_notifica_deposito(
      pnrecibo IN NUMBER,
      pctipcob IN NUMBER,
      piparcial IN NUMBER,
      pcmoneda IN NUMBER,
      psolicitud IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_prod_genericos.f_cobro_deposito';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := pnrecibo || ', pctipcob:' || pctipcob;
      error          NUMBER;
      v_seguros      NUMBER;   -- Bug 28462 - 07/10/2013 - HRE - Cambio de dimension SSEGURO
      v_poliza       NUMBER;   -- Bug 28462 - 07/10/2013 - HRE - Cambio de dimension SSEGURO
      vnumerr        NUMBER;
      v_produc       NUMBER;
      vcrespue       NUMBER;
   BEGIN
      BEGIN
         SELECT sseguro, npoliza, sproduc
           INTO v_seguros, v_poliza, v_produc
           FROM seguros
          WHERE nsolici = psolicitud;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               SELECT sseguro, npoliza, sproduc
                 INTO v_seguros, v_poliza, v_produc
                 FROM seguros
                WHERE npoliza = psolicitud;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 111122);
                  RAISE e_object_error;
            END;
      END;

      error := pac_preguntas.f_get_pregunpolseg(v_seguros, 4122, 'POL', vcrespue);

      UPDATE pregunpolseg
         SET crespue = vcrespue + piparcial
       WHERE sseguro = v_seguros
         AND cpregun IN(4122);

      error := pac_md_agensegu.f_set_datosapunte(v_poliza, v_seguros, NULL, 'DEPOSITO',
                                                 'Numero de ducumento SAP:' || pnrecibo
                                                 || CHR(10)
                                                 || 'Numero de propuesta/Poliza de Alta:'
                                                 || psolicitud || CHR(10)
                                                 || 'Monto del Depósito:' || piparcial,
                                                 35, 0, f_sysdate, f_sysdate, 0, null, mensajes);

      UPDATE psucontrolseg
         SET cnivelr = 1700
       WHERE sseguro = v_seguros
         AND ccontrol = 17182;

      UPDATE agensegu
         SET cestado = 1
       WHERE sseguro = v_seguros
         AND nlinea = (SELECT MAX(nlinea)
                         FROM agensegu a
                        WHERE a.sseguro = v_seguros);

      IF error = 0 THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;

      RETURN error;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 111122;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_notifica_deposito;
END pac_iax_prod_genericos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROD_GENERICOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROD_GENERICOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROD_GENERICOS" TO "PROGRAMADORESCSI";
