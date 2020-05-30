create or replace PACKAGE BODY pac_persistencia IS
   FUNCTION to_boolean(pin NUMBER)
      RETURN BOOLEAN IS
   BEGIN
      RETURN(pin = 1);   -- 1 TRUE otro valor false
   END;

   FUNCTION to_boolean(pin BOOLEAN)
      RETURN NUMBER IS
   BEGIN
      IF pin THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;

      RETURN 0;   -- uhmm
   END;

   FUNCTION f_inicializar_contexto(pidsession VARCHAR2)
      RETURN NUMBER IS
      v_dat_iax_produccion t_persis_produccion := t_persis_produccion();
      v_data_iax_suplemento t_persis_suplemento := t_persis_suplemento();
      v_data_iax_siniestro t_persis_siniestro := t_persis_siniestro();
      v_data_iax_simulacion t_persis_simulacion := t_persis_simulacion();
      v_data_iax_persona t_persis_persona := t_persis_persona();
      v_data_iax_comision t_persis_comision := t_persis_comision();
      v_data_iax_descuento t_persis_descuento := t_persis_descuento();
      v_dat_iaxpar_productos t_persis_iaxpar_productos := t_persis_iaxpar_productos();
      v_data_iax_fincas t_persis_fincas := t_persis_fincas();
      v_data_iax_facturas t_persis_facturas := t_persis_facturas();

      v_substr_session varchar2(100);

   BEGIN

      select  substr(pidsession, 1, decode(instr(pidsession, '.'), 0
                                   , length(pidsession)
                                   , instr(pidsession, '.') -1
                                   ))
       into v_substr_session
       from dual;

      BEGIN
         SELECT web_persis_produccion, web_persis_suplemento, web_persis_siniestro,
                web_persis_simulacion, web_persis_persona, web_persis_comision,
                web_persis_descuento, web_persis_iaxpar_productos, web_persis_fincas,
                web_persis_facturas
           INTO v_dat_iax_produccion, v_data_iax_suplemento, v_data_iax_siniestro,
                v_data_iax_simulacion, v_data_iax_persona, v_data_iax_comision,
                v_data_iax_descuento, v_dat_iaxpar_productos, v_data_iax_fincas,
                v_data_iax_facturas
           FROM web_persistencia
          WHERE idsession = v_substr_session;
             p_tab_error(f_sysdate, f_user, 'f_inicializar_contexto', 1, v_substr_session, 'He recuperado');

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         -- p_tab_error(f_sysdate, f_user, 'f_inicializar_contexto', 2, v_substr_session, 'No he  recuperado');
            v_dat_iax_produccion := t_persis_produccion(ob_persis_produccion());
            v_data_iax_suplemento := t_persis_suplemento(ob_persis_suplemento());
            v_data_iax_siniestro := t_persis_siniestro(ob_persis_siniestro());
            v_data_iax_simulacion := t_persis_simulacion(ob_persis_simulacion());
            v_data_iax_persona := t_persis_persona(ob_persis_persona());
            v_data_iax_comision := t_persis_comision(ob_persis_comision());
            v_data_iax_descuento := t_persis_descuento(ob_persis_descuento());
            v_dat_iaxpar_productos := t_persis_iaxpar_productos(ob_persis_iaxpar_productos());
            v_data_iax_fincas := t_persis_fincas(ob_persis_fincas);
            v_data_iax_facturas := t_persis_facturas(ob_persis_facturas);
      END;

      IF v_dat_iax_produccion IS NOT NULL THEN
       --p_tab_error(f_sysdate, f_user, 'f_inicializar_contexto', 3, v_substr_session, 'he  recuperado datos de produccion:'||v_dat_iax_produccion(1).vproducto||'-'||v_dat_iax_produccion(1).vagente);
         pac_iax_produccion.poliza := v_dat_iax_produccion(1).poliza;
         pac_iax_produccion.vempresa := v_dat_iax_produccion(1).vempresa;
         pac_iax_produccion.vproducto := v_dat_iax_produccion(1).vproducto;
         pac_iax_produccion.vmodalidad := v_dat_iax_produccion(1).vmodalidad;
         pac_iax_produccion.vccolect := v_dat_iax_produccion(1).vccolect;
         pac_iax_produccion.vcramo := v_dat_iax_produccion(1).vcramo;
         pac_iax_produccion.vctipseg := v_dat_iax_produccion(1).vctipseg;
         pac_iax_produccion.gidioma := v_dat_iax_produccion(1).gidioma;
         pac_iax_produccion.vagente := v_dat_iax_produccion(1).vagente;
         pac_iax_produccion.vsolicit := v_dat_iax_produccion(1).vsolicit;
         pac_iax_produccion.vssegpol := v_dat_iax_produccion(1).vssegpol;
         pac_iax_produccion.vnmovimi := v_dat_iax_produccion(1).vnmovimi;
         pac_iax_produccion.vfefecto := v_dat_iax_produccion(1).vfefecto;
         pac_iax_produccion.vfvencim := v_dat_iax_produccion(1).vfvencim;
         pac_iax_produccion.vpmode := v_dat_iax_produccion(1).vpmode;
         pac_iax_produccion.vsseguro := v_dat_iax_produccion(1).vsseguro;
         pac_iax_produccion.issuplem := to_boolean(v_dat_iax_produccion(1).issuplem);
         pac_iax_produccion.issimul := to_boolean(v_dat_iax_produccion(1).issimul);
         pac_iax_produccion.issave := to_boolean(v_dat_iax_produccion(1).issave);
         pac_iax_produccion.isneedtom := to_boolean(v_dat_iax_produccion(1).isneedtom);
         pac_iax_produccion.isnewsol := to_boolean(v_dat_iax_produccion(1).isnewsol);
         pac_iax_produccion.isconsult := to_boolean(v_dat_iax_produccion(1).isconsult);
         pac_iax_produccion.ismodifprop := to_boolean(v_dat_iax_produccion(1).ismodifprop);
         pac_iax_produccion.isaltagar := to_boolean(v_dat_iax_produccion(1).isaltagar);
         pac_iax_produccion.imodifgar := to_boolean(v_dat_iax_produccion(1).imodifgar);
         pac_iax_produccion.isbajagar := to_boolean(v_dat_iax_produccion(1).isbajagar);
         pac_iax_produccion.isaltacol := to_boolean(v_dat_iax_produccion(1).isaltacol);
         -- actualizamos el contexto
         pac_contexto.p_contextoasignaparametro('IAX_AGENTEPROD',
                                                v_dat_iax_produccion(1).vagenteprod);
      END IF;

      IF v_dat_iaxpar_productos IS NOT NULL THEN
         pac_iaxpar_productos.vproducto := v_dat_iaxpar_productos(1).vproducto;
         pac_iaxpar_productos.vcactivi := v_dat_iaxpar_productos(1).vcactivi;
         pac_iaxpar_productos.vmodalidad := v_dat_iaxpar_productos(1).vmodalidad;
         pac_iaxpar_productos.vempresa := v_dat_iaxpar_productos(1).vempresa;
         pac_iaxpar_productos.vidioma := v_dat_iaxpar_productos(1).vidioma;
         pac_iaxpar_productos.vccolect := v_dat_iaxpar_productos(1).vccolect;
         pac_iaxpar_productos.vcramo := v_dat_iaxpar_productos(1).vcramo;
         pac_iaxpar_productos.vctipseg := v_dat_iaxpar_productos(1).vctipseg;
      END IF;

      IF v_data_iax_suplemento IS NOT NULL THEN
         pac_iax_suplementos.lstmotmov := v_data_iax_suplemento(1).lstmotmov;
         pac_iax_suplementos.p_set_pendiente_emision(v_data_iax_suplemento(1).ispendentemetre);
      --
      END IF;

      IF v_data_iax_siniestro IS NOT NULL THEN
         pac_iax_siniestros.vgobsiniestro := v_data_iax_siniestro(1).vgobsiniestro;
         pac_iax_siniestros.vproductos := v_data_iax_siniestro(1).vproductos;
      END IF;

      IF v_data_iax_simulacion IS NOT NULL THEN
         pac_iax_simulaciones.simulacion := v_data_iax_simulacion(1).simulacion;
         pac_iax_simulaciones.isconsultsimul :=
                                           to_boolean(v_data_iax_simulacion(1).isconsultsimul);
         pac_iax_simulaciones.isparammismo_aseg :=
                                        to_boolean(v_data_iax_simulacion(1).isparammismo_aseg);
         pac_iax_simulaciones.contracsimul := to_boolean(v_data_iax_simulacion(1).contracsimul);
         pac_iax_simulaciones.islimpiartemporales :=
                                      to_boolean(v_data_iax_simulacion(1).islimpiartemporales);
      END IF;

      IF v_data_iax_persona IS NOT NULL THEN
         pac_iax_persona.persona := v_data_iax_persona(1).persona;
         pac_iax_persona.gidioma := v_data_iax_persona(1).gidioma;
         pac_iax_persona.v_obirpf := v_data_iax_persona(1).v_obirpf;
         pac_iax_persona.parpersonas := v_data_iax_persona(1).parpersonas;
      END IF;

      IF v_data_iax_comision IS NOT NULL THEN
         pac_iax_comisiones.t_comision := v_data_iax_comision(1).t_comision;
      END IF;

      IF v_data_iax_descuento IS NOT NULL THEN
         pac_iax_descuentos.t_descuento := v_data_iax_descuento(1).t_descuento;
      END IF;

      IF v_data_iax_fincas IS NOT NULL THEN
         pac_iax_direcciones.vfincas := v_data_iax_fincas(1).t_fincas;
      END IF;

      IF v_data_iax_facturas IS NOT NULL THEN
         pac_iax_facturas.vgobfactura := v_data_iax_facturas(1).vgobfactura;
      END IF;

      --
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         --p_tab_error(f_sysdate, f_user, 'f_inicializar_contexto', 1, pidsession, SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_guardar_contexto(pidsession VARCHAR2)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_dat_iax_produccion t_persis_produccion := t_persis_produccion(ob_persis_produccion());
      v_dat_iax_suplemento t_persis_suplemento := t_persis_suplemento(ob_persis_suplemento());
      v_dat_iax_siniestro t_persis_siniestro := t_persis_siniestro(ob_persis_siniestro());
      v_dat_iax_simulacion t_persis_simulacion := t_persis_simulacion(ob_persis_simulacion());
      v_dat_iax_persona t_persis_persona := t_persis_persona(ob_persis_persona());
      v_dat_iax_comision t_persis_comision := t_persis_comision(ob_persis_comision());
      v_dat_iax_descuento t_persis_descuento := t_persis_descuento(ob_persis_descuento());
      v_dat_iaxpar_productos t_persis_iaxpar_productos
                                    := t_persis_iaxpar_productos(ob_persis_iaxpar_productos());
      v_dat_iax_fincas t_persis_fincas := t_persis_fincas(ob_persis_fincas);
      v_dat_iax_facturas t_persis_facturas := t_persis_facturas(ob_persis_facturas);

      v_substr_session varchar2(100);

   BEGIN

      select  substr(pidsession, 1, decode(instr(pidsession, '.'), 0
                                   , length(pidsession)
                                   , instr(pidsession, '.') -1
                                   ))
       into v_substr_session
       from dual;

      -- p_tab_error(f_sysdate, f_user, 'f_guardar_contexto', 100, pidsession, SQLERRM);
      v_dat_iax_produccion(1).poliza := pac_iax_produccion.poliza;
      v_dat_iax_produccion(1).vempresa := pac_iax_produccion.vempresa;
      v_dat_iax_produccion(1).vproducto := pac_iax_produccion.vproducto;
      v_dat_iax_produccion(1).vmodalidad := pac_iax_produccion.vmodalidad;
      v_dat_iax_produccion(1).vccolect := pac_iax_produccion.vccolect;
      v_dat_iax_produccion(1).vcramo := pac_iax_produccion.vcramo;
      v_dat_iax_produccion(1).vctipseg := pac_iax_produccion.vctipseg;
      v_dat_iax_produccion(1).gidioma := pac_iax_produccion.gidioma;
      v_dat_iax_produccion(1).vagente := pac_iax_produccion.vagente;
      v_dat_iax_produccion(1).vsolicit := pac_iax_produccion.vsolicit;
      v_dat_iax_produccion(1).vssegpol := pac_iax_produccion.vssegpol;
      v_dat_iax_produccion(1).vnmovimi := pac_iax_produccion.vnmovimi;
      v_dat_iax_produccion(1).vfefecto := pac_iax_produccion.vfefecto;
      v_dat_iax_produccion(1).vfvencim := pac_iax_produccion.vfvencim;
      v_dat_iax_produccion(1).vpmode := pac_iax_produccion.vpmode;
      v_dat_iax_produccion(1).vsseguro := pac_iax_produccion.vsseguro;
      v_dat_iax_produccion(1).issuplem := to_boolean(pac_iax_produccion.issuplem);
      v_dat_iax_produccion(1).issimul := to_boolean(pac_iax_produccion.issimul);
      v_dat_iax_produccion(1).issave := to_boolean(pac_iax_produccion.issave);
      v_dat_iax_produccion(1).isneedtom := to_boolean(pac_iax_produccion.isneedtom);
      v_dat_iax_produccion(1).isnewsol := to_boolean(pac_iax_produccion.isnewsol);
      v_dat_iax_produccion(1).isconsult := to_boolean(pac_iax_produccion.isconsult);
      v_dat_iax_produccion(1).ismodifprop := to_boolean(pac_iax_produccion.ismodifprop);
      v_dat_iax_produccion(1).isaltagar := to_boolean(pac_iax_produccion.isaltagar);
      v_dat_iax_produccion(1).imodifgar := to_boolean(pac_iax_produccion.imodifgar);
      v_dat_iax_produccion(1).isbajagar := to_boolean(pac_iax_produccion.isbajagar);
      v_dat_iax_produccion(1).isaltacol := to_boolean(pac_iax_produccion.isaltacol);
      v_dat_iax_produccion(1).vagenteprod :=
         TO_NUMBER(NVL(pac_contexto.f_contextovalorparametro('IAX_AGENTEPROD'),
                       pac_contexto.f_contextovalorparametro('IAX_AGENTE')));
      --
      --
      -- relleno el objeto v_dat_IAXPAR_PRODUCTOS con lo que tenga en memoria
      --
      --
      v_dat_iaxpar_productos(1).vproducto := pac_iaxpar_productos.vproducto;
      v_dat_iaxpar_productos(1).vcactivi := pac_iaxpar_productos.vcactivi;
      v_dat_iaxpar_productos(1).vmodalidad := pac_iaxpar_productos.vmodalidad;
      v_dat_iaxpar_productos(1).vempresa := pac_iaxpar_productos.vempresa;
      v_dat_iaxpar_productos(1).vidioma := pac_iaxpar_productos.vidioma;
      v_dat_iaxpar_productos(1).vccolect := pac_iaxpar_productos.vccolect;
      v_dat_iaxpar_productos(1).vcramo := pac_iaxpar_productos.vcramo;
      v_dat_iaxpar_productos(1).vctipseg := pac_iaxpar_productos.vctipseg;
      -- fin relleno v_dat_iaxpar_productos
      --
      -- relleno el objeto v_data_iax_suplemento con lo que tenga en memoria
      --
      --
      v_dat_iax_suplemento(1).lstmotmov := pac_iax_suplementos.lstmotmov;
      v_dat_iax_suplemento(1).ispendentemetre := pac_iax_suplementos.f_get_pendiente_emision;
      --
      --
      -- relleno el objecto v_dat_siniestros
      v_dat_iax_siniestro(1).vgobsiniestro := pac_iax_siniestros.vgobsiniestro;
      v_dat_iax_siniestro(1).vproductos := pac_iax_siniestros.vproductos;
      --
      -- relleno el objeto v_data_iax_simulacion con lo que tenga en memoria
      --
      --
      v_dat_iax_simulacion(1).simulacion := pac_iax_simulaciones.simulacion;
      v_dat_iax_simulacion(1).isconsultsimul :=
                                               to_boolean(pac_iax_simulaciones.isconsultsimul);
      v_dat_iax_simulacion(1).isparammismo_aseg :=
                                            to_boolean(pac_iax_simulaciones.isparammismo_aseg);
      v_dat_iax_simulacion(1).contracsimul := to_boolean(pac_iax_simulaciones.contracsimul);
      v_dat_iax_simulacion(1).islimpiartemporales :=
                                          to_boolean(pac_iax_simulaciones.islimpiartemporales);
      v_dat_iax_persona(1).persona := pac_iax_persona.persona;
      v_dat_iax_persona(1).gidioma := pac_iax_persona.gidioma;
      v_dat_iax_persona(1).v_obirpf := pac_iax_persona.v_obirpf;
      v_dat_iax_persona(1).parpersonas := pac_iax_persona.parpersonas;
      --
      --
      v_dat_iax_comision(1).t_comision := pac_iax_comisiones.t_comision;
      v_dat_iax_descuento(1).t_descuento := pac_iax_descuentos.t_descuento;
      v_dat_iax_fincas(1).t_fincas := pac_iax_direcciones.vfincas;
      v_dat_iax_facturas(1).vgobfactura := pac_iax_facturas.vgobfactura;

      --
      BEGIN
         INSERT INTO web_persistencia
                     (idsession, web_persis_produccion, web_persis_suplemento,
                      web_persis_siniestro, web_persis_simulacion, web_persis_persona,
                      web_persis_comision, web_persis_descuento, web_persis_iaxpar_productos,
                      web_persis_fincas, web_persis_facturas, cusuari, fcreacion, facceso)
              VALUES (v_substr_session, v_dat_iax_produccion, v_dat_iax_suplemento,
                      v_dat_iax_siniestro, v_dat_iax_simulacion, v_dat_iax_persona,
                      v_dat_iax_comision, v_dat_iax_descuento, v_dat_iaxpar_productos,
                      v_dat_iax_fincas, v_dat_iax_facturas, f_user, SYSTIMESTAMP, NULL);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE web_persistencia
               SET web_persis_produccion = v_dat_iax_produccion,
                   web_persis_suplemento = v_dat_iax_suplemento,
                   web_persis_siniestro = v_dat_iax_siniestro,
                   web_persis_simulacion = v_dat_iax_simulacion,
                   web_persis_persona = v_dat_iax_persona,
                   web_persis_comision = v_dat_iax_comision,
                   web_persis_descuento = v_dat_iax_descuento,
                   web_persis_iaxpar_productos = v_dat_iaxpar_productos,
                   web_persis_fincas = v_dat_iax_fincas,
                   web_persis_facturas = v_dat_iax_facturas,
                   facceso = SYSTIMESTAMP
             WHERE idsession = v_substr_session;
      END;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_guardar_contexto', 100, pidsession, SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_limpiar_contexto(pidsession VARCHAR2)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_substr_session varchar2(100);

   BEGIN

      select  substr(pidsession, 1, decode(instr(pidsession, '.'), 0
                                   , length(pidsession)
                                   , instr(pidsession, '.') -1
                                   ))
       into v_substr_session
       from dual;

      pac_iax_suplementos.limpiartemporales;
      pac_iax_produccion.limpiartemporales;
      pac_iax_simulaciones.limpiartemporales;

      DELETE      web_persistencia
            WHERE idsession = v_substr_session;

      --DBMS_SESSION.modify_package_state(DBMS_SESSION.reinitialize);  -- lo quito de momento parece que puede dar errores en la BBDD
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_limpiar_contexto', 100, pidsession, SQLERRM);
         RETURN 1;
   END;

   FUNCTION f_limpiar_conexiones(pidsession VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      v_substr_session varchar2(100);

   BEGIN

      select  substr(pidsession, 1, decode(instr(pidsession, '.'), 0
                                   , length(pidsession)
                                   , instr(pidsession, '.') -1
                                   ))
       into v_substr_session
       from dual;

      IF pidsession IS NOT NULL THEN
         DELETE      web_persistencia
               WHERE idsession = v_substr_session;
      ELSE
         DELETE      web_persistencia
               WHERE facceso <= SYSTIMESTAMP - INTERVAL '90' MINUTE;   --minutos, de momento lo pongo fijo hasta que sepamos como poder parametrizarlo
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;   -- para evitar bloqueos
         p_tab_error(f_sysdate, f_user, 'f_limpiar_contexto', 100, pidsession, SQLERRM);
         RETURN 1;
   END;
END;
/