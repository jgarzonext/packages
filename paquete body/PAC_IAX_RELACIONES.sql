--------------------------------------------------------
--  DDL for Package Body PAC_IAX_RELACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_RELACIONES" IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_RELACIONES
      PROPÓSITO:    Funciones de la capa IAX para realizar acciones sobre la tabla RELACIONES

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/07/2012   APD             1. Creación del package. 0022494: MDP_A001- Modulo de relacion de recibos
   ******************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;

   /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in psrelacion     : codigo de la relacion
    param in pfiniefe     : Fecha de inicio de efecto , del recibo dentro de la relación
    param in pffinefe     : Fecha de fin del recibo, dentro de la relación
    param out prelaciones  : sys_refcursor de las relaciones que cumplan los busqueda
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_obtener_relaciones(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      psrelacion IN NUMBER,
      pfiniefe IN DATE,
      pffinefe IN DATE,
      prelaciones OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres:' || pcempres || ' - pcagente:' || pcagente
            || ' - psrelacion:' || psrelacion || ' - pfiniefe:'
            || TO_CHAR(pfiniefe, 'dd/mm/yyyy') || ' - pffinefe:'
            || TO_CHAR(pffinefe, 'dd/mm/yyyy');
      vobject        VARCHAR2(500) := 'pac_iax_relaciones.f_obtener_relaciones';
      vcursor        sys_refcursor;
   BEGIN
      vnumerr := pac_md_relaciones.f_obtener_relaciones(pcempres, pcagente, psrelacion,
                                                        pfiniefe, pffinefe, prelaciones,
                                                        mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF prelaciones%ISOPEN THEN
            CLOSE prelaciones;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF prelaciones%ISOPEN THEN
            CLOSE prelaciones;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF prelaciones%ISOPEN THEN
            CLOSE prelaciones;
         END IF;

         RETURN 1;
   END f_obtener_relaciones;

        /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
        PCAGENTE IN  NUMBER
        PCRELACION IN NUMBER
        PCTIPO IN NUNBER ( tipo de busqueda  DEFAULT 0)
        TSELECT OUT VARCHAR2

         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_set_recibos_relacion(
      pcagente IN NUMBER,
      pcrelacion IN NUMBER,
      pnrecibo IN NUMBER,
      pctipo IN NUMBER,
      ptob_iax_relaciones OUT t_iax_relaciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_md_relaciones.f_set_recibos_relacion';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pnrecibo:' || pnrecibo || ' - pcagente:' || pcagente
            || ' - psrelacion:' || pcrelacion || ' - pctipo:' || pctipo;
      pob_iax_relaciones ob_iax_relaciones;
   BEGIN
      vnumerr := pac_md_relaciones.f_set_recibos_relacion(pcagente, pcrelacion, pnrecibo,
                                                          pctipo, ptob_iax_relaciones,
                                                          mensajes);

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
   END f_set_recibos_relacion;

   /*
   F_GUARDAR_RECIBO EN_RELACION
    crear una nueva relación con todos los recibos que se han informado */
   FUNCTION f_guardar_recibo_en_relacion(
      ptiaxinfo IN t_iax_info,
      pcagente IN NUMBER,
      psrelacion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_md_relaciones.f_set_recibos_relacion';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pcagente:' || pcagente;
      pob_iax_relaciones ob_iax_relaciones;
      vtmsg          VARCHAR2(1000);
   BEGIN
      vnumerr := pac_md_relaciones.f_guardar_recibo_en_relacion(ptiaxinfo, pcagente,
                                                                psrelacion, mensajes);

      IF vnumerr != 0 THEN
         -- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      vtmsg := pac_iobj_mensajes.f_get_descmensaje(9904014, pac_md_common.f_get_cxtidioma);
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, vtmsg || ' - ' || psrelacion);
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
   END f_guardar_recibo_en_relacion;

   /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
    param in pnrecibo     : numero de recibo
    param out precibo     : sys_refcursor con el recibo que cumplan los busqueda
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_reg_retro_cobro_masivo(
      pnrecibo IN NUMBER,
      precibo OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vquery         VARCHAR2(3000);
      vobjectname    VARCHAR2(500) := 'pac_iax_relaciones.f_get_reg_retro_cobro_masivo';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pnrecibo:' || pnrecibo;
   BEGIN
      vnumerr := pac_md_relaciones.f_get_reg_retro_cobro_masivo(pnrecibo, precibo, mensajes);

      IF vnumerr != 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF precibo%ISOPEN THEN
            CLOSE precibo;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF precibo%ISOPEN THEN
            CLOSE precibo;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF precibo%ISOPEN THEN
            CLOSE precibo;
         END IF;

         RETURN 1;
   END f_get_reg_retro_cobro_masivo;

   /*************************************************************************
        Función que retrocede el cobro (impaga) una lista de recibos, con un
        motivo por recibo y a una fecha común.

          param in pcempres : Còdigo de empresa
          param in pnliqmen : Número de liquidación mensual
          param in plistrecibos: Lista de recibos y motivos de impago
          param in pfretro : Fecha de retrocesión de los cobros
          param in out mensaje : mensajes de error

          La lista de recibos/motivos tendrá como separador ";" para separar los
          recibos y "," para separar motivo de recibo, ejemplo:

          recibos1,motivo1;recibos2,motivo2;recibos3,motivo3;recibos4,motivo4;

          return : number
   *************************************************************************/
   FUNCTION f_set_retro_cobro_masivo(
      pcempres IN NUMBER,
      psproliq IN NUMBER,
      plistrecibos IN VARCHAR2,
      pfretro IN DATE,
      psmovagr OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vlista2        VARCHAR2(4000);
      vparam         VARCHAR2(4000)
         := 'parámetros - pcempres: ' || pcempres || ', psproliq: ' || psproliq
            || ' plistrecibos: ' || plistrecibos || ', pfretro: '
            || TO_CHAR(pfretro, 'dd/mm/yyyy');
      vobject        VARCHAR2(200) := 'PAC_MD_RELACIONES.f_set_retro_cobro_masivo';
      vnumerr        NUMBER;
   BEGIN
      vnumerr := pac_md_relaciones.f_set_retro_cobro_masivo(pcempres, psproliq, plistrecibos,
                                                            pfretro, psmovagr, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         -- 1000005 Objecto invocado con paràmetros erroneos
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         -- 1000006 Error al llamar procedimiento o función/SQL
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         -- 1000001 Error en la ejecución de PL/SQL
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_retro_cobro_masivo;

          /*************************************************************************
    Función que consulta los recibos retrocedibles sobre los que podremos
    retroceder el pago (impagarlos).

      param in pcempres : Còdigo de empresa
      param in psproliq : Número de proceso de la liquidación
      param in out mensaje : mensajes de error

      NOTA:
      Queda pendiente de considerar los recibos "por reemplazo":
      1. La query ha de excluirlos.
      2. Cuando la búsqueda es por recibo ha de avisar si lo es.

      Datos de la query:

        4. NANUALI - Anualidad
        5. NFRACCI - Fracción
        6. FCESTREC- F. Cobro
        7. TTIPCOB - T. Cobro (RECIBOS.CBANCAR IS NULL --> Domiciliado, ELSE --> Medidador)
        8. TPRODUC - Producto
        9. NPOLIZA - Nº póliza
        10.CAGENTE - Mediador
        11.ITOTALR - Total recibo
        12.NREMESA - Nº Remesa
        13.NLIQMEN - Nº Liquidación
        14.NRELREC - Nº Relación
        15.FEMISIO - Fecha emisión
        16.FEFECTO - Fecha efecto
        17.FVENCIM - Fecha vencimiento

      return : number
   *************************************************************************/
   FUNCTION f_get_retro_cobro_masivo(
      pcempres IN NUMBER,
      psproliq IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER(8) := 0;
      squery         VARCHAR2(4000);
      vpasexec       NUMBER(8) := 0;
      vnliqmen       liquidacab.nliqmen%TYPE;
      v_max_reg      NUMBER;   -- número màxim de registres mostrats
      vparam         VARCHAR2(500)
         := 'parámetros - pcempres: ' || pcempres || ', psproliq: ' || psproliq
            || ', pcidioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_ADM.F_GET_RETRO_COBRO_MASIVO';
      numrecs        NUMBER;
      vcidioma       NUMBER := NVL(pcidioma, pac_md_common.f_get_cxtidioma);
      cur            sys_refcursor;
      e_param_error  EXCEPTION;
   BEGIN
      vpasexec := 10;

      IF psproliq IS NULL
                         --  OR pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_relaciones.f_get_retro_cobro_masivo(pcempres, psproliq, pcidioma, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_retro_cobro_masivo;
END pac_iax_relaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_RELACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RELACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RELACIONES" TO "PROGRAMADORESCSI";
