--------------------------------------------------------
--  DDL for Package Body PAC_MD_RELACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_RELACIONES" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_RELACIONES
      PROPÓSITO:    Funciones de la capa MD para realizar acciones sobre la tabla RELACIONES

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      pobfacturas    ob_iax_facturas;
      vnumerr        NUMBER;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_md_relaciones.f_obtener_relaciones';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres:' || pcempres || ' - pcagente:' || pcagente
            || ' - psrelacion:' || psrelacion || ' - pfiniefe:'
            || TO_CHAR(pfiniefe, 'dd/mm/yyyy') || ' - pffinefe:'
            || TO_CHAR(pffinefe, 'dd/mm/yyyy');
   BEGIN
      vnumerr := pac_relaciones.f_obtener_relaciones(NVL(pcempres,
                                                         pac_md_common.f_get_cxtempresa),
                                                     NVL(pcagente,
                                                         pac_md_common.f_get_cxtagente),
                                                     psrelacion, pfiniefe, pffinefe,
                                                     pac_md_common.f_get_cxtidioma(), vquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      prelaciones := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF prelaciones%ISOPEN THEN
            CLOSE prelaciones;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF prelaciones%ISOPEN THEN
            CLOSE prelaciones;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_md_relaciones.f_set_recibos_relacion';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pnrecibo:' || pnrecibo || ' - pcagente:' || pcagente
            || ' - psrelacion:' || pcrelacion || ' - pctipo:' || pctipo;
      pob_iax_relaciones ob_iax_relaciones := ob_iax_relaciones();
   BEGIN
      vnumerr := pac_relaciones.f_set_recibos_relacion(NVL(pcagente,
                                                           pac_md_common.f_get_cxtagente),
                                                       pcrelacion, pnrecibo, pctipo,
                                                       pac_md_common.f_get_cxtidioma, vquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);
      ptob_iax_relaciones := t_iax_relaciones();

      LOOP
         FETCH cur
          INTO pob_iax_relaciones.cobliga, pob_iax_relaciones.nrecibo,
               pob_iax_relaciones.fefecto, pob_iax_relaciones.npoliza,
               pob_iax_relaciones.tomador, pob_iax_relaciones.riesgo,
               pob_iax_relaciones.srelacion, pob_iax_relaciones.liquido,
               pob_iax_relaciones.importe;

         EXIT WHEN cur%NOTFOUND;
         ptob_iax_relaciones.EXTEND;
         ptob_iax_relaciones(ptob_iax_relaciones.LAST) := pob_iax_relaciones;
         pob_iax_relaciones := ob_iax_relaciones();
         vpasexec := 6;
      END LOOP;

      CLOSE cur;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

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
      vobjectname    VARCHAR2(500) := 'pac_md_relaciones.f_guardar_recibo_en_relacion';
      vpasexec       NUMBER(5) := 1;
      vsrel          NUMBER;
      vparam         VARCHAR2(2000);
   BEGIN
      IF ptiaxinfo IS NOT NULL
         AND ptiaxinfo.COUNT > 0 THEN
         SELECT srelacion.NEXTVAL
           INTO psrelacion
           FROM DUAL;

         FOR i IN ptiaxinfo.FIRST .. ptiaxinfo.LAST LOOP
            IF ptiaxinfo(i).valor_columna IS NOT NULL THEN
               vnumerr :=
                  pac_relaciones.f_guardar_recibo_en_relacion
                                                          (ptiaxinfo(i).valor_columna,
                                                           NVL(pcagente,
                                                               pac_md_common.f_get_cxtagente),
                                                           psrelacion, 3);

               IF vnumerr <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                  RAISE e_object_error;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vquery         VARCHAR2(3000);
      cur            sys_refcursor;
      vobjectname    VARCHAR2(500) := 'pac_md_relaciones.f_get_reg_retro_cobro_masivo';
      vpasexec       NUMBER(5) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pnrecibo:' || pnrecibo;
   BEGIN
      vnumerr := pac_relaciones.f_get_reg_retro_cobro_masivo(pnrecibo,
                                                             pac_md_common.f_get_cxtidioma(),
                                                             vquery);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      precibo := pac_iax_listvalores.f_opencursor(vquery, mensajes);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vlista2        VARCHAR2(4000);
      vparam         VARCHAR2(4000)
         := 'parámetros - pcempres: ' || pcempres || ', psproliq: ' || psproliq
            || ' plistrecibos: ' || plistrecibos || ', pfretro: '
            || TO_CHAR(pfretro, 'dd/mm/yyyy');
      vobject        VARCHAR2(200) := 'PAC_MD_RELACIONES.f_set_retro_cobro_masivo';
      vnumerr        NUMBER;
      vnrecibo       NUMBER;
      vnpos          NUMBER;
      vcmotmov       NUMBER;
      vsmovagr       NUMBER;
      vcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
      vsproces       NUMBER;
      vnprolin       NUMBER;
      vsel           VARCHAR2(9000);
      vtexto         VARCHAR2(4000);
      vcempres       NUMBER := NVL(pcempres, pac_md_common.f_get_cxtempresa);

      TYPE t_cursor IS REF CURSOR;

      TYPE registre IS RECORD(
         cempres        NUMBER,
         cagente        NUMBER
      );

      rec            registre;
      c_nliqmen      t_cursor;
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      lv_appendstring VARCHAR2(4000) := plistrecibos;
      lv_resultstring VARCHAR2(500);
      lv_count       NUMBER;
   BEGIN
      IF plistrecibos IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 10;
      -- 9903999 Retrocesión de cobro masivo
      vtexto := f_axis_literales(9903999, vcidioma);
      vnumerr := f_procesini(f_user, vcempres, 'RETRO COBRO MASIVO', vtexto, vsproces);
      vpasexec := 20;

      -- 1. ANULAR O RETROCEDER EL COBRO (IMPAGAR)
      LOOP
         EXIT WHEN NVL(INSTR(lv_appendstring, ';'), -99) < 0;
         vpasexec := 30;
         lv_resultstring := SUBSTR(lv_appendstring, 1,(INSTR(lv_appendstring, ';') - 1));
         lv_count := INSTR(lv_appendstring, ';') + 1;
         lv_appendstring := SUBSTR(lv_appendstring, lv_count, LENGTH(lv_appendstring));
         vnpos := INSTR(lv_resultstring, ',');
         vnrecibo := SUBSTR(lv_resultstring, 1, vnpos - 1);
         vcmotmov := SUBSTR(lv_resultstring, vnpos + 1);

         IF vlista2 IS NULL THEN
            vlista2 := vnrecibo;
         ELSE
            vlista2 := vlista2 || ', ' || vnrecibo;
         END IF;

         vpasexec := 40;
         vnumerr := pac_devolu.f_impaga_rebut_2(vnrecibo, pfretro, NULL, vcmotmov, NULL,
                                                vsmovagr);
         psmovagr := vsmovagr;
         vpasexec := 50;

         IF vnumerr = 0 THEN
            -- 9000841 Impago de recibo realizado correctamente
            -- 9901743 Motivo Impago
            vpasexec := 55;
            vtexto := f_axis_literales(9000841, vcidioma) || ' ' || vnrecibo || ' '
                      || f_axis_literales(9901743, vcidioma) || ' ' || vcmotmov;
            vnumerr := f_proceslin(vsproces, vtexto, vnrecibo, vnprolin);
         ELSE
            -- 9901300 Error al realizar el impago de recibos
            -- 9901743 Motivo Impago
            vpasexec := 60;
            vtexto := f_axis_literales(9901300, vcidioma) || ' ' || vnrecibo || ' '
                      || f_axis_literales(9901743, vcidioma) || ' ' || vcmotmov || ' Error: '
                      || f_axis_literales(vnumerr, vcidioma);
            vnumerr := f_proceslin(vsproces, vtexto, vnrecibo, vnprolin);
            --
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;
      END LOOP;

      vnprolin := 0;
      vpasexec := 70;

      -- 2. LIQUIDACIÓN
      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'RETRO_COBRO_LIQ_AGE'), 0) = 1
         AND vlista2 IS NOT NULL THEN
         vpasexec := 80;
         vsel := 'SELECT DISTINCT L.CEMPRES, L.CAGENTE FROM RECIBOS L '
                 || ' WHERE L.NRECIBO IN (' || vlista2 || ')';
         vpasexec := 90;

         OPEN c_nliqmen FOR vsel;

         vpasexec := 100;

         LOOP
            vpasexec := 110;

            FETCH c_nliqmen
             INTO rec;

            vpasexec := 120;
            EXIT WHEN c_nliqmen%NOTFOUND;
            vpasexec := 130;
            vnumerr := pac_liquida.f_liquidaliq_age(rec.cagente, rec.cempres, 0,   -- Modo real
                                                    pfretro, vcidioma,
                                                    pac_md_common.f_get_cxtagente, vsproces,
                                                    vsmovagr);

            IF vnumerr = 0 THEN
               -- 9001776 - Liquidación de comisiones
               vtexto := f_axis_literales(9001776, vcidioma) || ' ' || rec.cagente;
            ELSE
               vtexto := f_axis_literales(9001776, vcidioma) || ' ' || rec.cagente
                         || ' Error: ' || f_axis_literales(vnumerr, vcidioma);
            END IF;

            vnprolin := NULL;
            vpasexec := 150;
            vnumerr := f_proceslin(vsproces, vtexto, rec.cagente, vnprolin);
         END LOOP;
      END IF;

      vpasexec := 200;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         -- 1000005 Objecto invocado con paràmetros erroneos
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         -- 1000006 Error al llamar procedimiento o función/SQL
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         -- 1000001 Error en la ejecución de PL/SQL
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vnumerr        NUMBER(8) := 0;
      squery         VARCHAR2(4000);
      vpasexec       NUMBER(8) := 0;
      --vnliqmen       liquidacab.nliqmen%TYPE;
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
                         -- OR pnrecibo IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      /*  IF pnliqmen IS NULL THEN
           SELECT MAX(nliqmen)
             INTO vnliqmen
             FROM liquidalin
            WHERE nrecibo = pnrecibo;
        ELSE*/-- END IF;

      /*   IF pnrecibo IS NOT NULL THEN
           -- Si la busqueda es para un recibo (PNRECIBO IS NOT NULL) y es
           -- de reemplazo se dará un aviso "Recibo de reemplazo"
           NULL;
        /*
        IF ¿POLIZA DE REEMPLADO? THEN
           -- 9904095 - Recibo de reemplazo
           pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9904095, vpasexec, vparam);
           RETURN NULL;
        END IF;
        */
      --  END IF;
      vpasexec := 20;
      squery :=
         'select distinct r.nrecibo, r.nanuali, r.nfracci,  m.fmovini FCOBRO, '
         || ' F_DESAGENTE_T(s.cagente) MEDIADOR, ' || ' ti.ttitulo PRODUCTO,' || ' s.npoliza,'
         || ' r.cagente,' || ' v.itotalr,' || psproliq || ' sproliq, '
         || ' x.srelacion nrelrec,' || ' r.femisio,' || ' r.fefecto,' || ' r.fvencim,'
         || ' decode(r.cbancar,null,f_axis_literales(9902262,' || vcidioma
         || '),f_axis_literales(9901930,' || vcidioma || ')) TCOBRO,'
         || ' decode(r.ctiprec,9,f_axis_literales(109474,' || vcidioma || '),13,'
         || ' f_axis_literales(109474,' || vcidioma || '),f_axis_literales(100895,' || vcidioma
         || ')) TTIPREC, x.srelacion RELACION'
         || ' from relaciones x, vdetrecibos v, seguros s, '
         || '      titulopro ti, movrecibo m, recibos r ,liquidalin l, liquidacab b'
         || '  where  f_cestrec(r.nrecibo, null) = 1 ' || '  and m.fmovfin is null '
         || '  and m.nrecibo = r.nrecibo ' || '  and v.nrecibo = r.nrecibo '
         || '  and x.nrecibo (+) = r.nrecibo ' || '  and x.ffinefe (+) is null '
         || '  and s.sseguro = r.sseguro ' || '  and ti.cmodali = s.cmodali'
         || '  and ti.ctipseg = s.ctipseg' || '  and ti.ccolect = s.ccolect'
         || '  and ti.cramo = s.cramo' || '  and ti.cidioma =' || vcidioma
         || '  and b.cempres = l.cempres and b.cagente = l.cagente and b.nliqmen = l.nliqmen '
         || '  and l.nrecibo = r.nrecibo and b.sproliq = ' || psproliq || '  and l.cempres = '
         || pcempres;
      vpasexec := 30;
      v_max_reg := pac_parametros.f_parinstalacion_n('N_MAX_REG');
      vpasexec := 60;
      squery := squery || ' order by R.NRECIBO desc ';
      vpasexec := 70;

      IF v_max_reg IS NOT NULL THEN
         IF INSTR(squery, 'order by', -1, 1) > 0 THEN
            -- se hace de esta manera para mantener el orden de los registros
            squery := 'select * from (' || squery || ') where rownum <= ' || v_max_reg;
         ELSE
            squery := squery || ' and rownum <= ' || v_max_reg;
         END IF;
      END IF;

      vpasexec := 80;
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);

      IF pac_md_log.f_log_consultas(squery, 'PAC_MD_RELACIONES.F_GET_RETRO_COBRO_MASIVO', 1, 2,
                                    mensajes) <> 0 THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

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
END pac_md_relaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_RELACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RELACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_RELACIONES" TO "PROGRAMADORESCSI";
