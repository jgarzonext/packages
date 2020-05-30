CREATE OR REPLACE PACKAGE BODY PAC_MD_UTILES IS
   /******************************************************************************
      NOMBRE:    PAC_MD_UTILES
      PROPÓSITO: Funciones con utilidades transversales

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/10/2016  JAE              1. Creaciónn del objeto.
      2.0        21/06/2019  SGM              2. IAXIS-4134 Reporte de acuerdo de pag
      3.0        28/05/2020  ECP              3. IAXIS-13945. Error pagador póliza
   ******************************************************************************/

   /*************************************************************************
      Retorna el importe aplicando la tasa de cambio
      param in  p_moneda_inicial : Moneda origen
      param in  p_moneda_final   : Moneda destino
      param in  p_fecha          : Fecha de cambio
      param in  p_importe        : Valor
      param in  p_redondear      : Redondear. Defecto 1
      param out p_cambio         : Tasa de cambio
      param out mensajes         : mensajes de error
      return                     : Importe aplicando tasa de cambio
   *************************************************************************/
   FUNCTION f_importe_cambio(p_moneda_inicial IN eco_tipocambio.cmonori%TYPE,
                             p_moneda_final   IN OUT eco_tipocambio.cmondes%TYPE,
                             p_fecha          IN eco_tipocambio.fcambio%TYPE,
                             p_importe        IN NUMBER,
                             p_cambio         OUT NUMBER,
                             mensajes         IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec NUMBER := 1;
      vobject  VARCHAR2(200) := 'pac_md_utiles.f_importe_cambio';
      vparam   VARCHAR2(500);
      --
      v_f_cambio DATE;
      cmonpol    NUMBER;
      cmonpolint VARCHAR2(3);
      tmonpol    VARCHAR2(200);

   BEGIN
      --
      IF p_moneda_final IS NULL
      THEN
         cmonpol        := pac_parametros.f_parinstalacion_n('MONEDAINST');
         tmonpol        := pac_md_listvalores.f_get_tmoneda(cmonpol,
                                                            cmonpolint,
                                                            mensajes);
         p_moneda_final := cmonpolint;
      END IF;
      --
      v_f_cambio := pac_eco_tipocambio.f_fecha_max_cambio(pmonori => p_moneda_inicial,
                                                          pmondes => p_moneda_final,
                                                          pfecha  => NVL(p_fecha,
                                                                         TRUNC(f_sysdate)));
      --
      IF TRUNC(v_f_cambio) < TRUNC(f_sysdate) AND TRUNC(p_fecha) = TRUNC(f_sysdate)
      THEN
         --
         pac_iobj_mensajes.crea_nuevo_mensaje(mens   => mensajes,
                                              tipo   => 2,
                                              nerror => 9909819);
         --
      END IF;
      --
      p_cambio := pac_eco_tipocambio.f_cambio(p_moneda_inicial,
                                              p_moneda_final,
                                              v_f_cambio);
      --
      RETURN pac_eco_tipocambio.f_importe_cambio(p_moneda_inicial,
                                                 p_moneda_final,
                                                 v_f_cambio,
                                                 p_importe);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN 1;
   END f_importe_cambio;

   /*************************************************************************
      FUNCTION f_get_user_comp: Retorna la información usu_datos

      param in pscontgar : Agente
      param in mensajes  : t_iax_mensajes
      return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_user_comp(pcuser   IN VARCHAR2,
                            mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_md_utiles.f_get_user_comp';
      vparam   VARCHAR2(500) := 'pcuser: ' || pcuser;
      --
   BEGIN
      --
      OPEN v_cursor FOR
         SELECT c.*
           FROM usuarios  u,
                companias c
          WHERE u.cusuari = pcuser
            AND u.sperson = c.sperson;
      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_user_comp;

   /*************************************************************************
      FUNCTION f_get_hisprocesosrea: Retorna la información de hisprocesosrea

      param in pcnomtabla   : Nombre tabla
      param in pcnomcampo   : Nombre campo
      param in pcusuariomod : Usuario modifica
      param in pfmodifi_ini : Fecha inicio
      param in pfmodifi_fin :	Fecha fin
      param in mensajes     : t_iax_mensajes
      return                : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_hisprocesosrea(pcnomtabla   IN VARCHAR2,
                                 pcnomcampo   IN VARCHAR2,
                                 pcusuariomod IN VARCHAR2,
                                 pfmodifi_ini DATE,
                                 pfmodifi_fin DATE,
                                 mensajes     IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR IS
      --
      v_cursor SYS_REFCURSOR;
      --
      vpasexec NUMBER;
      vobject  VARCHAR2(200) := 'pac_md_utiles.f_get_hisprocesosrea';
      vparam   VARCHAR2(500) := 'pcnomtabla: ' || pcnomtabla || ' pcnomcampo: ' ||
                                pcnomcampo || ' pcusuariomod: ' || pcusuariomod ||
                                ' pfmodifi_ini: ' || pfmodifi_ini ||
                                ' pfmodifi_fin: ' || pfmodifi_fin;
      --
   BEGIN
      --
      OPEN v_cursor FOR
         SELECT h.*
           FROM his_procesosrea h
          WHERE h.cnomtabla = NVL(pcnomtabla,
                                  h.cnomtabla)
            AND h.cnomcampo = NVL(pcnomcampo,
                                  h.cnomcampo)
            AND h.cusuariomod = NVL(pcusuariomod,
                                    h.cusuariomod)
            AND h.fmodifi BETWEEN (NVL(pfmodifi_ini,
                                       h.fmodifi)) AND
                (NVL(pfmodifi_fin,
                     h.fmodifi));
      --
      RETURN v_cursor;
      --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000005,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000006,
                                           vpasexec,
                                           vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                           vobject,
                                           1000001,
                                           vpasexec,
                                           vparam,
                                           psqcode  => SQLCODE,
                                           psqerrm  => SQLERRM);
         RETURN NULL;
   END f_get_hisprocesosrea;


    FUNCTION f_set_acuerdo_prima(
          pnnumide IN VARCHAR2,
          ptomador IN VARCHAR2,
          pcodsucursal IN NUMBER,
          psucursal IN VARCHAR2,
          pdireccion IN VARCHAR2,
          ptelefono_fijo IN VARCHAR2,
          ptelefono_celular IN VARCHAR2,
          pnnumide_rep IN VARCHAR2,
          prepresentante IN VARCHAR2,
          pvalor IN NUMBER,
          plugar IN VARCHAR2,
          pfecha IN DATE,
          pnro_cuotas IN NUMBER,
          pcrepresentante IN NUMBER,
          pidacuerdo out number,
          pcusuario IN VARCHAR2,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER IS

        vpasexec NUMBER := 1;
        vobject  VARCHAR2(200) := 'pac_md_utiles.f_set_acuerdo_prima';
        vparam   VARCHAR2(500);
        vsperson per_personas.sperson%type;
        vctipide per_personas.ctipide%type;
        vnnumide per_personas.nnumide%type;
        vcount number:=0;
        vdigitov varchar2(4);
        vnumero varchar2(30);

        BEGIN
          SELECT NVL(MAX(id+1),1) INTO pidacuerdo  from TMP_ACUERDO_PAGO;

         --INI 12/04/2020 JRVG IAXIS-5319 REPORTE ACUERDOS DE PAGO
          select p.sperson, p.ctipide into vsperson,vctipide from per_personas p where p.nnumide = pnnumide;       

          if vctipide = 37 then

            select length(pnnumide) into vcount from dual;

            select substr(pnnumide,vcount,1) into vdigitov from dual;  --- digito de verificacion
            select ltrim(replace(to_char(substr(pnnumide,1,(vcount-1)),'9,999,999,999,999'),',','.')) into vnumero from dual;  

             vnnumide:= vnumero ||'-'|| vdigitov ;

          else 
              select ltrim(replace(to_char(pnnumide,'9,999,999,999,999'),',','.')) into vnnumide from dual;  

          end if;

          insert into tmp_acuerdo_pago (id, nnumide, tomador, codsucursal, sucursal, direccion, telefono_fijo, telefono_celular, nnumide_rep,
          representante, valor, lugar, fecha, nro_cuotas, crepresentante,nnumide_format, cusuario)
          values (pidacuerdo,pnnumide, upper(ptomador), pcodsucursal, upper(psucursal), upper(pdireccion), ptelefono_fijo, ptelefono_celular, pnnumide_rep,f_nombre_persona(vsperson,1,null), pvalor, initcap(plugar),
          trunc(pfecha), pnro_cuotas, pcrepresentante,vnnumide,pcusuario);
          --FIN 12/04/2020 JRVG IAXIS-5319 REPORTE ACUERDOS DE PAGO

          RETURN 0;

          EXCEPTION
              WHEN e_param_error THEN
                 pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                   vobject,
                                                   1000005,
                                                   vpasexec,
                                                   vparam);
                 RETURN 1;
              WHEN e_object_error THEN
                 pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                   vobject,
                                                   1000006,
                                                   vpasexec,
                                                   vparam);
                 RETURN 1;
              WHEN OTHERS THEN
                 pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                   vobject,
                                                   1000001,
                                                   vpasexec,
                                                   vparam,
                                                   psqcode  => SQLCODE,
                                                   psqerrm  => SQLERRM);
                 RETURN 1;

     END f_set_acuerdo_prima;


    FUNCTION f_set_det_acuerdo_prima(
          pidacuerdo IN NUMBER,
          pnro_cuota IN NUMBER,
          pporcentaje IN NUMBER,
          pvalor IN NUMBER,
          pfecha_pago IN DATE,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER IS

        vpasexec NUMBER := 1;
        vobject  VARCHAR2(200) := 'pac_md_utiles.f_set_det_acuerdo_prima';
        vparam   VARCHAR2(500);


        BEGIN

         --INI 12/04/2020 JRVG IAXIS-5319 REPORTE ACUERDOS DE PAGO
         -- INSERT INTO TMP_DET_ACUERDO_PAGO (ID_ACUERDO_PAGO, NRO_CUOTA, PORCENTAJE, VALOR, FECHA_PAGO) VALUES (pidacuerdo, pnro_cuota, pporcentaje, pvalor, TO_DATE(pfecha_pago, 'YYYY-MM-DD'));
         INSERT INTO TMP_DET_ACUERDO_PAGO (ID_ACUERDO_PAGO, NRO_CUOTA, PORCENTAJE, VALOR, FECHA_PAGO) VALUES (pidacuerdo, pnro_cuota, pporcentaje, pvalor, TRUNC(pfecha_pago));
         --FIN 12/04/2020 JRVG IAXIS-5319 REPORTE ACUERDOS DE PAGO

          RETURN 0;

          EXCEPTION
              WHEN e_param_error THEN
                 pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                   vobject,
                                                   1000005,
                                                   vpasexec,
                                                   vparam);
                 RETURN 1;
              WHEN e_object_error THEN
                 pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                   vobject,
                                                   1000006,
                                                   vpasexec,
                                                   vparam);
                 RETURN 1;
              WHEN OTHERS THEN
                 pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                   vobject,
                                                   1000001,
                                                   vpasexec,
                                                   vparam,
                                                   psqcode  => SQLCODE,
                                                   psqerrm  => SQLERRM);
                 RETURN 1;

     END f_set_det_acuerdo_prima;


    FUNCTION f_set_polizas_acuerdo_prima(
          pidacuerdo IN NUMBER,
          npoliza IN VARCHAR2,
          nrecibo IN VARCHAR2,  --SGM 4134 REPORTE CUOTAS ACUERDOS DE PAGO
          nsaldo IN NUMBER,     --SGM 4134 REPORTE CUOTAS ACUERDOS DE PAGO
          pvalor IN NUMBER,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER IS

        vpasexec NUMBER := 1;
        vobject  VARCHAR2(200) := 'pac_md_utiles.f_set_polizas_acuerdo_prima';
        vparam   VARCHAR2(500);


        BEGIN

          INSERT INTO TMP_POLIZAS_ACUERDO_PAGO (ID_ACUERDO_PAGO, NPOLIZA, NRECIBO,SALDO, VALOR) VALUES (pidacuerdo, npoliza, nrecibo,nsaldo, pvalor);

          RETURN 0;

          EXCEPTION
              WHEN e_param_error THEN
                 pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                   vobject,
                                                   1000005,
                                                   vpasexec,
                                                   vparam);
                 RETURN 1;
              WHEN e_object_error THEN
                 pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                   vobject,
                                                   1000006,
                                                   vpasexec,
                                                   vparam);
                 RETURN 1;
              WHEN OTHERS THEN
                 pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                   vobject,
                                                   1000001,
                                                   vpasexec,
                                                   vparam,
                                                   psqcode  => SQLCODE,
                                                   psqerrm  => SQLERRM);
                 RETURN 1;

     END f_set_polizas_acuerdo_prima;

	 FUNCTION f_get_tipiva(
          psseguro IN NUMBER,
          pnriesgo IN NUMBER,
          vtipiva out number,
          mensajes OUT t_iax_mensajes
      )
        RETURN NUMBER IS
         vnumerr        NUMBER(8) := 0;
          vpasexec NUMBER := 1;
          vobject  VARCHAR2(200) := 'pac_md_utiles.f_get_tipiva';
          vparam   VARCHAR2(500):= 'psseguro'||psseguro||' pnriesgo'||pnriesgo;

           v_formula      VARCHAR2(32000);
           TYPE t_parametros IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
           v_parms        t_parametros;
           psesion        NUMBER := 1;
           a              NUMBER;
           vtexto         VARCHAR2(32000);
           vclave         NUMBER;
           IVA_PROVINCIARIESGO     NUMBER;
           IVA_NORMAL              NUMBER;
           ENTIDAD_EXC_IVA         NUMBER;

         BEGIN
         
         --IAXIS-13945 -- 28/05/2020

         select nvl(PAC_IMPUESTOS_CONF.F_IVA_PROVINCIARIESGO('EST', psseguro, pnriesgo),0) into IVA_PROVINCIARIESGO from dual;
          --IAXIS-13945 -- 28/05/2020
         select PAC_IMPUESTOS_CONF.F_ENTIDAD_EXC_IVA('EST', psseguro) into ENTIDAD_EXC_IVA from dual;

         select ptipiva into IVA_NORMAL from tipoiva where CTIPIVA = 1 AND FFINVIG IS NULL;

         v_formula := 'IMPUESTO_IVA';
         v_parms('IVA_PROVINCIARIESGO') := IVA_PROVINCIARIESGO;
         v_parms('IVA_NORMAL') := IVA_NORMAL; 

         vnumerr := pac_sgt.del(psesion); 

         SELECT formula, clave INTO vtexto, vclave FROM sgt_formulas WHERE codigo = v_formula;
         vtexto:= REPLACE( vtexto, 'PAC_IMPUESTOS_CONF.F_ENTIDAD_EXC_IVA(''EST'',SSEGURO)', ENTIDAD_EXC_IVA);

         FOR reg IN (SELECT * FROM sgt_trans_formula WHERE clave = vclave) LOOP
            vnumerr := pac_sgt.put(psesion, reg.parametro, v_parms(reg.parametro));
            IF vnumerr <> 0 OR v_parms(reg.parametro) IS NULL THEN
              RAISE e_param_error;
            END IF;
         END LOOP;

         vtipiva := pk_formulas.eval(vtexto, psesion);
         vnumerr := pac_sgt.del(psesion);

        RETURN vnumerr;

           EXCEPTION
                WHEN e_param_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000005,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN e_object_error THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000006,
                                                     vpasexec,
                                                     vparam);
                   RETURN 1;
                WHEN OTHERS THEN
                   pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                                     vobject,
                                                     1000001,
                                                     vpasexec,
                                                     vparam,
                                                     psqcode  => SQLCODE,
                                                     psqerrm  => SQLERRM);
                   RETURN 1;

     END f_get_tipiva;

END pac_md_utiles;
/
