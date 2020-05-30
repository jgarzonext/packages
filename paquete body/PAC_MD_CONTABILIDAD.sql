--------------------------------------------------------
--  DDL for Package Body PAC_MD_CONTABILIDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CONTABILIDAD" AS
/******************************************************************************
   NOMBRE:    PAC_MD_CONTABILIDAD
   PROPÓSITO: Contiene el módulo de contabilidad de la capa MD

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/07/2008  SBG              1. Creación del package.
   2.0        06/07/2009  DCT              2. Modificar función f_get_consultadesglose
   3.0        21/07/2009  DCT              3. Modificar p_cierra_contabilidad.
   4.0        03/05/2010  JMF              4. 0014356: CEM800 - Modificació en l'interficie comptable
   5.0        09/09/2010  JMF              5. 0014782: APR708 - Llistat detall de la comptabilitat diaria
   6.0        14/12/2010  ICV              6. 0016908: APRM - Contabilidad diaria
   7.0        23/12/2010  ICV              7. 0017033: CEM800 - Contabilidad - Proteger el cierre para que no se pueda hacer sobre un cálculo acumulado
   8.0        29/06/2011  ICV              8. 0018917: MSGV003 - Comptabilitat: El detall de la comptabilitat diaria no funciona.
   9.0        17/07/2012  DCG              9. 0022394: AGM003-AGM - Contabilida no cuadra
  10.0        23/04/2013  APD             10. 0026777: LCOL_F003-Ejecutar el proceso de contabilidad diaria en modo batch
  11.0        09/10/2014  MMM             11. 0033018: 0014809: Generar en modo BATCH la interface de contabilidad
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Función que genera la contabilidad
      param in P_EMPRESA    : código empresa
      param in P_ANY        : año
      parma in P_MES        : mes
      parma in P_NMESES     : nº de meses para generar la contabilidad
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_genera_contabilidad(
      p_empresa IN NUMBER,
      p_any IN NUMBER,
      p_mes IN NUMBER,
      p_nmeses IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA=' || p_empresa || ', P_ANY=' || p_any || ', P_MES=' || p_mes
            || ', P_NMESES=' || p_nmeses;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_genera_contabilidad';
      vfecha         DATE;
   BEGIN
      --Comprovació pas de paràmetres
      IF p_empresa IS NULL
         OR p_any IS NULL
         OR p_mes IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Comprovació de que el mes NO estigui tancat i de que el núm. de mesos sigui > 1
      vpasexec := 2;
      vfecha := LAST_DAY(TO_DATE('01/' || p_mes || '/' || p_any, 'dd/mm/yyyy'));
      vpasexec := 3;

      IF pac_cuadre_adm.f_esta_cerrado(p_empresa, vfecha) <> 0
         AND NVL(p_nmeses, 0) <= 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 107855);
         RAISE e_object_error;
      END IF;

      -- Creación de la contabilidad:

      --1.  Se han de cargar las tablas de cuadre.
      vpasexec := 4;
      pac_cuadre_adm.p_cuadre_recibos(p_any, p_mes, p_empresa, p_nmeses);
      --2.  Se han de cargar las tablas contables.
      vpasexec := 5;
      pac_cuadre_adm.p_contabiliza(p_empresa, vfecha, p_nmeses);
      --3.  Si se han cargado correctamente las tablas, hemos de mostrar el mensaje 111107 (Cuadro cargado correctamente).
      vpasexec := 6;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111107);
      COMMIT;   --BUG 7174 - 17/06/2009 - DCT
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
   END f_genera_contabilidad;

   /*************************************************************************
      Procedimiento que genera el cierre definitivo de la contabilidad y generará un fichero de traspaso
      param in P_EMPRESA    : código empresa
      param in P_FECHA      : Último día del mes
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   PROCEDURE p_cierra_contabilidad(
      p_empresa IN NUMBER,
      p_fecha IN DATE,
      p_nmeses IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                := 'P_EMPRESA=' || p_empresa || ', P_FECHA=' || TO_CHAR(p_fecha, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.p_cierra_contabilidad';
      vmap           VARCHAR2(10);
      verror         NUMBER;
      vfichero       VARCHAR2(200);
      v_tdesmap      VARCHAR2(100);
      v_fmovimi      DATE;
   BEGIN
      --Comprovació pas de paràmetres
      vpasexec := 1;

      IF p_empresa IS NULL
         OR p_fecha IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Comprovació de que el mes NO estigui tancat
      vpasexec := 2;

      IF pac_cuadre_adm.f_esta_cerrado(p_empresa, p_fecha) <> 0
         AND NVL(p_nmeses, 0) <= 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 107855);
         RAISE e_object_error;
      END IF;

      --Ini Bug.: 0017033 - ICV - 17/12/2010

      --Control que no se pueda cerrar el mes actual
      IF TO_CHAR(p_fecha, 'mmrrrr') = TO_CHAR(f_sysdate, 'mmrrrr') THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901741);
         RAISE e_object_error;
      END IF;

      SELECT MAX(fasient)
        INTO v_fmovimi
        FROM contab
       WHERE fmovimi = (SELECT MAX(fmovimi)
                          FROM contab
                         WHERE cempres = p_empresa);

      IF TO_CHAR(v_fmovimi, 'mm') <> TO_CHAR(p_fecha, 'mm') THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901736);
         p_tab_error(f_sysdate, f_user, 'PAC_MD_SINIESTROS', 1,
                     'v_fmovimi : ' || v_fmovimi || ' p_fecha : ' || p_fecha, SQLERRM);
         RAISE e_object_error;
      END IF;

      --Fin Bug.: 17033

      --Traspaso de las tablas de simulación a las históricas.
      vpasexec := 3;
      pac_cuadre_adm.p_traspaso_his(p_empresa, p_fecha);
      --Generación del fichero de traspaso
      vpasexec := 4;
      vmap := pac_cuadre_adm.f_obtener_map(p_empresa);
      vpasexec := 5;
      COMMIT;   --BUG 7174 - 17/06/2009 - DCT
      --BUG 0010576 - 21/07/2009 - DCT - Contabilidad: Extracción correcta del detalle de las cuentas
      --Conseguimos el nombre del fichero. p_fecha_p_empresa-MODELSAP.txt
      -- BUG 0014356 - 03/05/2010 - JMF: Si en map lleva la # indica que es una variable a reemplazar.
      vpasexec := 6;

      BEGIN
         SELECT   /*TO_CHAR(p_fecha, 'ddmmyyyy') || '_' || p_empresa || '-' || tdesmap*/
                DECODE(INSTR(tdesmap, '#'),
                       0, TO_CHAR(p_fecha, 'ddmmyyyy') || '_' || p_empresa || '-' || tdesmap,
                       REPLACE(tdesmap, '#DDMMYYYY', TO_CHAR(p_fecha, 'ddmmyyyy')))
           INTO v_tdesmap
           FROM map_cabecera
          WHERE cmapead = vmap;
      EXCEPTION
         WHEN OTHERS THEN
            v_tdesmap := NULL;
      END;

      vpasexec := 7;
      verror := pac_map.f_extraccion(vmap,
                                     TO_CHAR(p_fecha, 'DDMMYYYY') || '|' || TO_CHAR(p_empresa),
                                     v_tdesmap, vfichero);

      IF NVL(verror, 0) <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror, verror);
      ELSE
         --Todo OK. Mensaje: Se ha cerrado el mes.
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 110675);
      END IF;

      --FI BUG 0010576 - 21/07/2009 - DCT - Contabilidad: Extracción correcta del detalle de las cuentas
      vpasexec := 10;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END p_cierra_contabilidad;

   /*************************************************************************
      Función que selecciona info sobre la simulación de la contabilidad según parám.
      param in P_EMPRESA    : código empresa
      param in P_ANY        : año
      parma in P_MES        : mes
      param in P_PAIS       : código país. Si se informa, la etiqueta será su descripción, sino será "TODOS"
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consultasimulacion(
      p_empresa IN NUMBER,
      p_any IN NUMBER,
      p_mes IN NUMBER,
      p_pais IN NUMBER DEFAULT NULL,
      p_nmeses IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA=' || p_empresa || ', P_ANY=' || p_any || ', P_MES=' || p_mes
            || ', P_PAIS=' || p_pais;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_get_ConsultaSimulacion';
      vsquery        VARCHAR2(1000);
      v_part_1       VARCHAR2(1000);
      v_part_2       VARCHAR2(1000);
      v_tpais        VARCHAR2(100);   -- Nom del pais
      v_q_pais       VARCHAR2(25);   -- Part de la query referent al cpais
      cur            sys_refcursor;
      v_fecha        DATE;
   BEGIN
      --Comprovació de que el mes NO estigui tancat
      v_fecha := LAST_DAY(TO_DATE('01/' || p_mes || '/' || p_any, 'dd/mm/yyyy'));

      IF pac_cuadre_adm.f_esta_cerrado(p_empresa, v_fecha) <> 0
         AND NVL(p_nmeses, 0) <= 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 107855);
         RAISE e_object_error;
      END IF;

      -- Busquem les parts variables de la query
      IF p_pais IS NULL THEN
         vpasexec := 2;

         SELECT UPPER(tlitera)
           INTO v_tpais
           FROM literales
          WHERE cidioma = pac_md_common.f_get_cxtidioma
            AND slitera = 111141;   -- "Todos"
      ELSE
         vpasexec := 3;
         v_q_pais := v_q_pais || ' AND cpais = ' || p_pais;

         SELECT REPLACE(tpais, '''', '´') tpais
           INTO v_tpais
           FROM despaises
          WHERE cidioma = pac_md_common.f_get_cxtidioma
            AND cpais = p_pais;
      END IF;

      IF NVL(f_parinstalacion_n('CONTAB_X_ASIENT'), 0) <> 1 THEN
         vpasexec := 4;
         v_part_1 :=

            -- ' SELECT NULL nasient, NULL nlinea, NULL slitera, NULL cpais, d.cempres, d.fasient, c.tdescri, d.ccuenta ccuenta, c.ccuenta ccuenta_interno,';
            ' SELECT NULL nasient, NULL nlinea, NULL slitera, NULL cpais, d.cempres, d.fasient, c.tdescri, d.ccuenta ccuenta, c.ccuenta ccuenta_interno,';
         v_part_1 :=
            v_part_1
            || ' DECODE (SIGN(SUM(DECODE (tasient, ''D'', iasient, 0-iasient))), 1, SUM(DECODE (tasient, ''D'', iasient, 0-iasient)), 0, 0) debe,';
         v_part_1 :=
            v_part_1
            || ' DECODE (SIGN(SUM(DECODE (tasient, ''H'', iasient, 0-iasient))), 1, SUM(DECODE (tasient, ''H'', iasient, 0-iasient))) haber,';

         -- v_part_2 :=
         --    ' GROUP BY d.cempres, d.fasient, d.ccuenta, c.tdescri, c.ccuenta, d.cpais ORDER BY TO_NUMBER(d.ccuenta)';

         --BUG 0007174 - 08/06/2009  - DCT
         --Se modificará el pac_md_contabilidad para que si no se selecciona por país, las selects de búsqueda no agrupen por país (apareciendo menos registros).
         IF p_pais IS NULL THEN
            v_part_2 :=
               ' GROUP BY d.cempres, d.fasient, d.ccuenta, c.tdescri, c.ccuenta ORDER BY TO_NUMBER(d.ccuenta)';
         ELSE
            v_part_2 :=
               ' GROUP BY d.cempres, d.fasient, d.ccuenta, c.tdescri, c.ccuenta, d.cpais ORDER BY TO_NUMBER(d.ccuenta)';
         END IF;
      ELSE
         vpasexec := 5;
         v_part_1 :=
            ' SELECT d.nasient, d.nlinea, c.slitera, d.cpais, d.cempres, d.fasient, c.tdescri, d.ccuenta ccuenta, c.ccuenta ccuenta_interno,';
         v_part_1 :=
            v_part_1
            || ' DECODE(SIGN((DECODE(tasient, ''D'', iasient, 0-iasient))), 1, (DECODE(tasient, ''D'', iasient, 0-iasient)), 0, 0) debe,';
         v_part_1 :=
            v_part_1
            || ' DECODE(SIGN((DECODE(tasient, ''H'', iasient, 0-iasient))), 1, (DECODE(tasient, ''H'', iasient, 0-iasient))) haber,';
         v_part_2 := ' ORDER BY nasient, nlinea';
      END IF;

      vpasexec := 6;
      -- Muntem la query
      vsquery := v_part_1;
      vsquery := vsquery || ' ''' || v_tpais || ''' pais,';

      --BUG 0007174 - 08/06/2009  - DCT
      IF p_pais IS NOT NULL THEN
         vsquery := vsquery
                    || ' (SELECT TPAIS FROM DESPAISES WHERE CPAIS = d.CPAIS AND CIDIOMA = '
                    || pac_md_common.f_get_cxtidioma || ') TPAIS,';
      END IF;

      vsquery := vsquery || ' '''
                 || TO_CHAR(LAST_DAY(TO_DATE(p_any || '/' || LPAD(p_mes, 2, '0'), 'yyyy/mm')),
                            'DD/MM/YYYY')
                 || ''' fecha_contable';
      vsquery := vsquery || ' FROM DESCUENTA c, DETCONTAB d, DETMODCONTA m';
      vsquery := vsquery || ' WHERE SUBSTR(d.ccuenta,1,length(c.ccuenta)) = c.ccuenta';
      vsquery :=
         vsquery
         || ' AND m.cempres = d.cempres and m.smodcon = d.nasient and m.nlinea = d.nlinea and c.ccuenta = m.ccuenta';
      vsquery := vsquery || ' AND d.cempres = ' || p_empresa;
      vsquery := vsquery || ' AND fasient = last_day(to_date(' || p_any || ' || ''/'' || lpad('
                 || p_mes || ', 2, ''0''), ''yyyy/mm''))';
      vsquery := vsquery || v_q_pais;
      vsquery := vsquery || v_part_2;
      vpasexec := 7;
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
   END f_get_consultasimulacion;

   /*************************************************************************
      Función que selecciona info sobre el histórico de la contabilidad según parám.
      param in P_EMPRESA    : código empresa
      param in P_ANY        : año
      parma in P_MES        : mes
      param in P_PAIS       : código país. Si se informa, la etiqueta será su descripción, sino será "TODOS"
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consultahistorico(
      p_empresa IN NUMBER,
      p_any IN NUMBER,
      p_mes IN NUMBER,
      p_pais IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA=' || p_empresa || ', P_ANY=' || p_any || ', P_MES=' || p_mes
            || ', P_PAIS=' || p_pais;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_get_ConsultaHistorico';
      vsquery        VARCHAR2(1000);
      v_part_1       VARCHAR2(1000);
      v_part_2       VARCHAR2(1000);
      v_tpais        VARCHAR2(100);   -- Nom del pais
      v_q_pais       VARCHAR2(250);   -- Part de la query referent al cpais
      v_q_from       VARCHAR2(250);   -- Part de la query referent al FROM
      cur            sys_refcursor;
   BEGIN
      -- Busquem les parts variables de la query
      IF p_pais IS NULL THEN
         vpasexec := 2;

         SELECT UPPER(tlitera)
           INTO v_tpais
           FROM literales
          WHERE cidioma = pac_md_common.f_get_cxtidioma
            AND slitera = 111141;   -- "Todos"
      ELSE
         vpasexec := 3;
         v_q_pais := v_q_pais || ' AND cpais = ' || p_pais;

         SELECT REPLACE(tpais, '''', '´') tpais
           INTO v_tpais
           FROM despaises
          WHERE cidioma = pac_md_common.f_get_cxtidioma
            AND cpais = p_pais;
      END IF;

      IF NVL(f_parinstalacion_n('CONTAB_X_ASIENT'), 0) <> 1 THEN
         vpasexec := 4;
         v_part_1 :=
               ' SELECT h.cempres, h.fconta, h.ccuenta, c.ccuenta ccuenta_interno, h.tdescri,';
         v_part_1 :=
            v_part_1
            || ' DECODE(SIGN(SUM(NVL(debe, 0) - NVL(haber, 0))), 1, SUM(NVL(debe, 0) - NVL(haber, 0)) ) debe,';
         v_part_1 :=
            v_part_1
            || ' DECODE(SIGN(SUM(NVL(haber, 0) - NVL(debe, 0))), 1, SUM(NVL(haber, 0) - NVL(debe, 0)) ) haber,';
         v_q_from := ' FROM HIS_CONTABLE h , DESCUENTA c';
         v_part_2 :=
            ' GROUP BY h.cempres, h.fconta, h.ccuenta, c.ccuenta, h.tdescri ORDER BY TO_NUMBER(h.ccuenta)';
      ELSE
         vpasexec := 5;
         v_part_1 :=
            ' SELECT h.cempres, h.nlinea, h.fconta, h.nasient, c.ccuenta ccuenta_interno, h.ccuenta, h.tdescri,';
         v_part_1 :=
            v_part_1
            || ' DECODE(SIGN((NVL(debe, 0) - NVL(haber, 0))), 1, (NVL(debe, 0) - NVL(haber, 0))) debe,';
         v_part_1 :=
            v_part_1
            || ' DECODE(SIGN((NVL(haber, 0) - NVL(debe, 0))), 1, (NVL(haber, 0) - NVL(debe, 0))) haber,';
         v_part_1 := v_part_1 || ' h.cpais,';
         v_q_from := ' FROM HIS_CONTAB_ASIENT h, DESCUENTA c';
         v_part_2 := ' ORDER BY h.nasient, h.nlinea';
      END IF;

      vpasexec := 6;
      -- Muntem la query
      vsquery := v_part_1;
      vsquery := vsquery || ' ''' || v_tpais || ''' pais,';
      vsquery := vsquery || 'to_date(' || ' '''
                 || TO_CHAR(LAST_DAY(TO_DATE(p_any || '/' || LPAD(p_mes, 2, '0'), 'yyyy/mm')),
                            'DD/MM/YYYY')
                 || ''' ,''dd/mm/yyyy'') fasient ';
      vsquery := vsquery || v_q_from;
      vsquery := vsquery || ' WHERE h.cempres = ' || p_empresa;
      vsquery := vsquery || ' AND SUBSTR(h.ccuenta,1,length(c.ccuenta)) = c.ccuenta ';
      vsquery := vsquery || ' AND h.fconta = last_day(to_date(' || p_any
                 || ' || ''/'' || lpad(' || p_mes || ', 2, ''0''), ''yyyy/mm''))';
      vsquery := vsquery || v_q_pais;
      vsquery := vsquery || v_part_2;
      vpasexec := 7;
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
   END f_get_consultahistorico;

   /*************************************************************************
      Función que selecciona info sobre el desglose de la contabilidad según parám.
      param in P_CUENTA     : código cuenta contable
      param in P_CONCEPTO   : tipo de concepto (Debe o Haber)
      param in P_EMPRESA    : código empresa
      param in P_FECHA      : fecha contable
      param in P_PAIS       : código país. Si se informa, la etiqueta será su descripción, sino será "TODOS"
      parma in P_LINEA      : código línea contable
      parma in P_ASIENTO    : código asiento contable
      parma in P_ACTUAL     : 0=Histórico / 1=Cuadre
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consultadesglose(
      p_cuenta IN VARCHAR2,
      p_concepto IN VARCHAR2,
      p_empresa IN NUMBER,
      p_fecha IN DATE,
      p_pais IN NUMBER DEFAULT NULL,
      p_linea IN NUMBER DEFAULT NULL,
      p_asiento IN NUMBER,
      p_actual IN NUMBER,
      pmes IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300)
         := 'P_CUENTA=' || p_cuenta || ', P_CONCEPTO=' || p_concepto || ', P_EMPRESA='
            || p_empresa || ', P_FECHA=' || TO_CHAR(p_fecha, 'DD/MM/YYYY') || ', P_PAIS='
            || p_pais || ', P_LINEA=' || p_linea || ', P_ASIENTO=' || p_asiento
            || ', P_ACTUAL=' || p_actual;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_get_ConsultaDesglose';
      v_tpais        VARCHAR2(100);   -- Nom del pais
      vdcuenta       VARCHAR2(100);   -- Desc. compte contable
      vconcept       VARCHAR2(5);   -- Desc. concepte (Debe/Haber)
      vqcuenta       VARCHAR2(32000);   -- Query que retorna PAC_CUADRE_ADM
      vsquery        VARCHAR2(32000);
      cur            sys_refcursor;
      v_nmax         NUMBER := 1000;
      vsquery_compta VARCHAR2(32000);
      v_quants       NUMBER;
   BEGIN
      -- Busquem el pais
      IF p_pais IS NULL THEN
         vpasexec := 2;

         SELECT UPPER(tlitera)
           INTO v_tpais
           FROM literales
          WHERE cidioma = pac_md_common.f_get_cxtidioma
            AND slitera = 111141;   -- "Todos"
      ELSE
         vpasexec := 3;

         SELECT REPLACE(tpais, CHR(39), CHR(39) || CHR(39))
           INTO v_tpais
           FROM despaises
          WHERE cidioma = pac_md_common.f_get_cxtidioma
            AND cpais = p_pais;
      END IF;

      vpasexec := 4;

      -- Busquem la desc. compte contable
      SELECT REPLACE(f_axis_literales(slitera, pac_md_common.f_get_cxtidioma), CHR(39),
                     CHR(39) || CHR(39))
        INTO vdcuenta
        FROM descuenta
       WHERE ccuenta = p_cuenta;

      vpasexec := 5;

      -- Busquem la desc. del concepte
      SELECT tatribu
        INTO vconcept
        FROM detvalores
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND catribu = p_concepto
         AND cvalor = 19;

      -- Busquem la query
      IF NVL(f_parinstalacion_n('CONTAB_X_ASIENT'), 0) <> 1 THEN
         vpasexec := 6;
         vqcuenta := pac_cuadre_adm.f_selec_cuenta(p_cuenta, p_concepto, p_fecha, p_empresa,
                                                   p_actual, pmes);
      ELSE
         vpasexec := 7;
         vqcuenta := pac_cuadre_adm.f_selec_cuenta_asient(p_cuenta, p_linea, p_asiento,
                                                          p_concepto, p_fecha, p_empresa,
                                                          p_actual);
      END IF;

      -- Bug10576 - 06/07/2009 - DCT  - IAX - Contabilidad: Extracción correcta del detalle de las cuentas
      --BUG 7174 18/06/2009 - DCT
      -- Haurem de posar un alies a les selects que ho requereixi
      vqcuenta := REPLACE(vqcuenta, '0), ', '0) importe,');
      -- FI Bug10576 - 06/07/2009 - DCT  - IAX - Contabilidad: Extracción correcta del detalle de las cuentas
      vpasexec := 8;

      -- Bug0022394 - 17/07/2012 - DCG  - Ini
      IF vqcuenta IS NOT NULL THEN
         -- Bug0022394 - 17/07/2012 - DCG  - Fi
         -- Comptem primer quants registres retorna la select, perquè si es passa de v_nmax,
         -- treiem un missatge per pantalla avisant de que n'hi ha més dels que es visualitzen.
         vsquery_compta := ' SELECT COUNT(1) FROM (' || vqcuenta || ')';
         cur := pac_md_listvalores.f_opencursor(vsquery_compta, mensajes);

         FETCH cur
          INTO v_quants;

         CLOSE cur;

         IF v_quants > v_nmax THEN
            pac_iobj_mensajes.crea_nuevo_mensaje_var(mensajes, 2, 9001372,
                                                     v_quants || '#' || v_nmax, 1);
         END IF;

         vpasexec := 9;
         -- Muntem les columnes addicionals sobre la query retornada anteriorment
         vsquery := ' SELECT ''' || v_tpais || ''' pais,';
         vsquery := vsquery || ' ''' || TO_CHAR(p_fecha, 'DD/MM/YYYY') || ''' fecha_contable,';
         vsquery := vsquery || ' ''' || vdcuenta || ''' cuenta_contable,';
         vsquery := vsquery || ' ''' || vconcept || ''' concepto, ';
         vsquery := vsquery || ' kk.* FROM (' || vqcuenta || ') kk WHERE ROWNUM <= ' || v_nmax;
         vpasexec := 10;
         cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      -- Bug0022394 - 17/07/2012 - DCG  - Ini
      END IF;

      -- Bug0022394 - 17/07/2012 - DCG  - Fi
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
   END f_get_consultadesglose;

   /*************************************************************************
      Función que recupera plantillas contables según parámetros de entrada
      param in P_EMPRESA    : código empresa
      param in P_TIPO_AS    : tipo asiento
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consultaplantilla(
      p_empresa IN NUMBER,
      p_tipo_as IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_modconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'P_EMPRESA=' || p_empresa || ', P_TIPO_AS=' || p_tipo_as;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.F_Get_ConsultaPlantilla';
      v_result       t_iax_modconta := t_iax_modconta();

      CURSOR cur IS
         SELECT m.*
           FROM modconta m
          WHERE cempres = p_empresa
            AND(p_tipo_as IS NULL
                OR(p_tipo_as IS NOT NULL
                   AND casient = p_tipo_as));   --AND    FINI <= TRUNC(F_SYSDATE)
   --AND    (FFIN IS NULL OR TRUNC(FFIN) > TRUNC(F_SYSDATE));
   BEGIN
      FOR c IN cur LOOP
         vpasexec := 2;
         v_result.EXTEND;
         v_result(v_result.LAST) := ob_iax_modconta();
         v_result(v_result.LAST).smodcon := c.smodcon;
         v_result(v_result.LAST).cempres := c.cempres;
         v_result(v_result.LAST).casient := c.casient;
         v_result(v_result.LAST).fini := c.fini;
         v_result(v_result.LAST).ffin := c.ffin;
         vpasexec := 3;

         SELECT tatribu
           INTO v_result(v_result.LAST).tasient
           FROM detvalores
          WHERE cidioma = pac_md_common.f_get_cxtidioma
            AND catribu = v_result(v_result.LAST).casient
            AND cvalor = 132;

         vpasexec := 4;

         SELECT tempres
           INTO v_result(v_result.LAST).tempres
           FROM empresas
          WHERE cempres = c.cempres;
      END LOOP;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_consultaplantilla;

   /*************************************************************************
      Función que inserta/modifica las plantillas contables
      param in P_EMPRESA    : código empresa
      param in P_TIPO_AS    : tipo asiento
      param in P_FFIN       : fecha final
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_grabar_plantilla(
      p_empresa IN NUMBER,
      p_tipo_as IN NUMBER,
      p_ffin IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_modconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA=' || p_empresa || ', P_TIPO_AS=' || p_tipo_as || ', P_FFIN='
            || TO_CHAR(p_ffin, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.F_Grabar_Plantilla';
      v_error        NUMBER;
      v_modcon       NUMBER(6);
      v_result       ob_iax_modconta := ob_iax_modconta();
   BEGIN
      pac_contabilidad.p_grabar_plantilla(p_empresa, NULL, p_tipo_as, NULL, p_ffin, v_modcon,
                                          v_error);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, v_error, vpasexec, vparam);
         RETURN NULL;
      END IF;

      vpasexec := 2;
      v_result := pac_md_contabilidad.f_recupera_plantilla(v_modcon, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_grabar_plantilla;

   /*************************************************************************
      Función que recupera los detalles de una plantilla contable
      param in P_EMPRESA    : código empresa
      param in P_SMODCON    : cod.de plantilla contable
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_get_consultadetalleplantilla(
      p_empresa IN NUMBER,
      p_smodcon IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_detmodconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'P_EMPRESA=' || p_empresa || ', P_SMODCON=' || p_smodcon;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.F_Get_ConsultaDetallePlantilla';
      v_result       t_iax_detmodconta := t_iax_detmodconta();

      CURSOR cur IS
         SELECT   m.smodcon, m.cempres, m.cprogra, m.nlinea, m.cclavep, m.cclaven, m.tdescri,
                  m.ccuenta, m.ccompan, m.cme, m.cbaja, m.tcuenta,
                  NVL(tscuadre, SUBSTR(d.tseldia, 1, 3000)) tscuadre, ROWNUM num_seq
             FROM detmodconta m, detmodconta_dia d
            WHERE m.cempres = d.cempres(+)
              AND m.smodcon = d.smodcon(+)
              AND m.nlinea = d.nlinea(+)
              AND m.cempres = p_empresa
              AND m.smodcon = p_smodcon
         ORDER BY nlinea;
   BEGIN
      FOR c IN cur LOOP
         vpasexec := 2;
         v_result.EXTEND;
         v_result(v_result.LAST) := ob_iax_detmodconta();
         v_result(v_result.LAST).smodcon := c.smodcon;
         v_result(v_result.LAST).cempres := c.cempres;
         v_result(v_result.LAST).nlinea := c.nlinea;
         v_result(v_result.LAST).tdescri := c.tdescri;
         v_result(v_result.LAST).ccuenta := c.ccuenta;
         v_result(v_result.LAST).tcuenta := c.tcuenta;
         v_result(v_result.LAST).tscuadre := c.tscuadre;
         v_result(v_result.LAST).num_seq := c.num_seq;
      END LOOP;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_consultadetalleplantilla;

   /*************************************************************************
      Función que borra un detalle de una plantilla contable
      param in P_EMPRESA    : código empresa
      param in P_SMODCON    : cod.de plantilla contable
      param in P_NLINEA     : número de línea
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_del_detalleplantilla(
      p_empresa IN NUMBER,
      p_smodcon IN NUMBER,
      p_nlinea IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'P_EMPRESA=' || p_empresa || ', P_SMODCON=' || p_smodcon || ', P_NLINEA='
            || p_nlinea;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.F_Del_DetallePlantilla';
      v_error        NUMBER;
   BEGIN
      pac_contabilidad.p_del_detalleplantilla(p_smodcon, p_empresa, p_nlinea, v_error);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, v_error, vpasexec, vparam);
         RETURN 1;
      END IF;

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
   END f_del_detalleplantilla;

   /*************************************************************************
      Función que inserta/modifica las plantillas contables
      param in P_EMPRESA    : código empresa
      param in P_SMODCON    : cod.de plantilla contable
      param in P_NLINEA     : núm. línia
      param in P_TDESCRI    : descripción
      param in P_CUENTAC    : cuenta contable
      param in P_TIPOLIN    : tipo línea
      param in P_TSELECT    : select
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_grabar_detalleplantilla(
      p_empresa IN NUMBER,
      p_smodcon IN NUMBER,
      p_nlinea IN NUMBER,
      p_tdescri IN VARCHAR2,
      p_cuentac IN VARCHAR2,
      p_tipolin IN NUMBER,
      p_tselect IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_detmodconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'P_EMPRESA=' || p_empresa || ', P_SMODCON=' || p_smodcon || ', P_TDESCRI='
            || p_tdescri || ', P_CUENTAC=' || p_cuentac || ', P_TIPOLIN=' || p_tipolin
            || ', P_TSELECT=' || p_tselect;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.F_Grabar_DetallePlantilla';
      v_nlinea       NUMBER;
      v_error        NUMBER;
      v_result       ob_iax_detmodconta;
      v_tcuen        VARCHAR2(1);
   BEGIN
      SELECT DECODE(p_tipolin, 1, 'D', 2, 'H')
        INTO v_tcuen
        FROM DUAL;

      vpasexec := 2;
      pac_contabilidad.p_grabar_detalleplantilla(p_smodcon, p_empresa, p_nlinea, p_tdescri,
                                                 p_cuentac, v_tcuen, p_tselect, v_nlinea,
                                                 v_error);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, v_error, vpasexec, vparam);
         RETURN NULL;
      END IF;

      vpasexec := 3;
      v_result := pac_md_contabilidad.f_recupera_detalleplantilla(p_empresa, p_smodcon,
                                                                  v_nlinea, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_grabar_detalleplantilla;

   /*************************************************************************
      Función que carga el objeto OB_IAX_MODCONTA
      param in P_SMODCON    : cod.de plantilla contable
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_recupera_plantilla(p_smodcon IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_modconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000) := 'P_SMODCON=' || p_smodcon;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.F_Recupera_Plantilla';
      v_error        NUMBER;
      v_result       ob_iax_modconta := ob_iax_modconta();
   BEGIN
      FOR c IN (SELECT *
                  FROM modconta
                 WHERE smodcon = p_smodcon) LOOP
         vpasexec := 2;
         v_result.smodcon := c.smodcon;
         v_result.cempres := c.cempres;
         v_result.casient := c.casient;
         v_result.fini := c.fini;
         v_result.ffin := c.ffin;
         vpasexec := 3;

         SELECT tatribu
           INTO v_result.tasient
           FROM detvalores
          WHERE cidioma = pac_md_common.f_get_cxtidioma
            AND catribu = v_result.casient
            AND cvalor = 132;
      END LOOP;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_recupera_plantilla;

   /*************************************************************************
      Función que carga el objeto OB_IAX_DETMODCONTA
      param in P_EMPRESA    : código empresa
      param in P_SMODCON    : cod.de plantilla contable
      param in P_NLINEA     : número de línea
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_recupera_detalleplantilla(
      p_empresa IN NUMBER,
      p_smodcon IN NUMBER,
      p_nlinea IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_detmodconta IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'P_EMPRESA=' || p_empresa || ', P_SMODCON=' || p_smodcon || ', P_NLINEA='
            || p_nlinea;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.F_Recupera_DetallePlantilla';
      v_error        NUMBER;
      v_result       ob_iax_detmodconta;
   BEGIN
      FOR c IN (SELECT d.*, ROWNUM num_seq
                  FROM detmodconta d
                 WHERE d.cempres = p_empresa
                   AND d.smodcon = p_smodcon
                   AND d.nlinea = p_nlinea) LOOP
         vpasexec := 2;
         v_result.smodcon := c.smodcon;
         v_result.cempres := c.cempres;
         v_result.nlinea := c.nlinea;
         v_result.tdescri := c.tdescri;
         v_result.ccuenta := c.ccuenta;
         v_result.tcuenta := c.tcuenta;
         v_result.tscuadre := c.tscuadre;
         v_result.num_seq := c.num_seq;
      END LOOP;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_recupera_detalleplantilla;

   /*************************************************************************
      Función que duplica un modelo contable e informa la fecha de fin
      del modelo del parámetro
      param in P_EMPRESA    : código empresa
      param in P_SMODCON    : cod. de plantilla contable
      param in out P_NEWSMOD: Nuevo cod. de plantilla contable
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_duplicarmodelo(
      p_empresa IN NUMBER,
      p_smodcon IN NUMBER,
      p_newsmod IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000) := 'P_SMODCON=' || p_smodcon;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_DuplicarModelo';
      v_error        NUMBER;
   BEGIN
      pac_contabilidad.p_duplicarmodelo(p_empresa, p_smodcon, p_newsmod, v_error);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, v_error, vpasexec, vparam);
         RETURN 1;
      END IF;

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
   END f_duplicarmodelo;

   /*************************************************************************
      Función que devuelve un sys_refcursor con los registros de la contabilidad diaria filtrado por los parametros
      del modelo del parámetro
      param in  pcempres : código empresa
      param in  pfcontabini : fecha de contabilidad inicial
      param in  pfcontabfin : fecha de contabilidad final
      param in  pftraspasini : fecha de traspaso inicial
      param in  pftraspasfin : fecha de traspaso inicial
      param in  pchecktraspas : traspasados o no
      param out  pcontdiarias : Cursor con los resultados
      param in out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_get_contabilidad_diaria(
      pcempres IN NUMBER,
      pfcontabini IN DATE,
      pfcontabfin IN DATE,
      pftraspasini IN DATE,
      pftraspasfin IN DATE,
      pfadminini IN DATE,
      pfadminfin IN DATE,
      pchecktraspas IN NUMBER,
      pcontdiarias OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'pcempres=' || pcempres || ', pfcontabini=' || pfcontabini || ', pfcontabfin='
            || pfcontabfin || ', pftraspasini=' || pftraspasini || ', pftraspasfin='
            || pftraspasfin || ', pfadminini=' || pfadminini || ', pfadminfin=' || pfadminfin
            || ', pchecktraspas=' || pchecktraspas;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_get_contabilidad_diaria';
      vnum_err       NUMBER(1) := 0;
      vquery         VARCHAR2(3000);
      vcempres       NUMBER;
   BEGIN
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vnum_err := pac_contabilidad.f_get_contabilidad_diaria(vcempres, pfcontabini,
                                                             pfcontabfin, pftraspasini,
                                                             pftraspasfin, pfadminini,
                                                             pfadminfin, pchecktraspas, vquery);
      -- p_control_error('xpl', 'query', vquery);
      pcontdiarias := pac_md_listvalores.f_opencursor(vquery, mensajes);
      --  p_control_error('xpl', 'vnum_err', vnum_err);
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
   END f_get_contabilidad_diaria;

   /*************************************************************************
      Función que acaba ejecutando la contabilidad diaria (por una fecha contable)
      del modelo del parámetro
      param in  pcempres : código empresa
      param in  pfcontabilidad : fecha de contabilidad inicial
      param in out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_contabiliza_diario(
      pcempres IN NUMBER,
      pfcontabilidad IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
                           := 'pcempres=' || pcempres || ', pfcontabilidad=' || pfcontabilidad;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_contabiliza_diario';
      vnum_err       NUMBER;
      vcempres       NUMBER;
      --Bug 37097 KJSC 14/09/2015 AVISO DE CONTABILIDAD YA GENERADA.
      e_salida       EXCEPTION;
   BEGIN
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vpasexec := 2;

      -- Bug 26777 - APD - 23/04/2013 - se valida si la contabilidad diaria debe
      -- ejecutar por JOB o no
      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'CONTA_JOB'), 0) = 1 THEN
         vpasexec := 3;

         DECLARE
            FUNCTION f_nulos(p_camp IN VARCHAR2, p_tip IN NUMBER DEFAULT 1)
               RETURN VARCHAR2 IS
            BEGIN
               vpasexec := 4;

               IF p_camp IS NULL THEN
                  RETURN ' null';
               ELSE
                  IF p_tip = 2 THEN
                     RETURN ' to_date(' || CHR(39) || p_camp || CHR(39) || ',''ddmmyyyy'')';
                  ELSE
                     RETURN ' ' || p_camp;
                  END IF;
               END IF;
            END;
         BEGIN
            vpasexec := 5;

            -- validar que no existan 2 jobs
            SELECT COUNT(1)
              INTO vnum_err
              FROM user_jobs
             WHERE UPPER(what) LIKE 'P_EJECUTAR_CONTABILIDAD%';

            IF vnum_err > 0 THEN
               -- Ya existe un proceso de contabilidad activo
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905453);
               RAISE e_object_error;
            END IF;

            vpasexec := 6;
            vnum_err := pac_jobs.f_ejecuta_job(NULL,
                                               'P_EJECUTAR_CONTABILIDAD(' || ' '
                                               || f_nulos(vcempres) || ',' || ' '
                                               || f_nulos(TO_CHAR(pfcontabilidad, 'ddmmyyyy'),
                                                          2) || ');',
                                               NULL);

            IF vnum_err > 0 THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ' men=' || vnum_err);
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, vnum_err);
               RETURN 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                           vparam || ' men=' || vnum_err, SQLCODE || ' ' || SQLERRM);
               pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                                 psqcode => SQLCODE, psqerrm => SQLERRM);
               RETURN 1;
         END;

         vpasexec := 7;
         -- Proceso en ejecución.
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9905454);
         RETURN 0;
      ELSE
         vpasexec := 8;
         -- fin Bug 26777 - APD - 23/04/2013
         vnum_err := pac_cuadre_adm.f_contabiliza_diario(vcempres, pfcontabilidad);

         --INI Bug 37097 KJSC 14/09/2015 AVISO DE CONTABILIDAD YA GENERADA.
         /*IF vnum_err <> 0 THEN
            RAISE e_object_error;
         END IF;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);*/
         IF vnum_err = 9908449 THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9908449, vpasexec, vparam);
            RAISE e_salida;
         ELSIF vnum_err <> 0 THEN
            RAISE e_object_error;
         ELSE
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
         END IF;
      --Fin Bug 37097 KJSC 14/09/2015 AVISO DE CONTABILIDAD YA GENERADA.
      END IF;

      vpasexec := 9;
      RETURN vnum_err;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN e_salida THEN
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_contabiliza_diario;

   /*************************************************************************
      Función que ejecuta el map 321
      param in  pcempres : código empresa
      param out  pnomfichero : Nombre fichero
   *************************************************************************/
   FUNCTION f_traspasar(
      pcempres IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pfadminini IN DATE,
      pfadminfin IN DATE,
      pnomfichero OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000) := 'pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_traspasar';
      vnum_err       NUMBER := 0;
      vcempres       NUMBER;
   BEGIN
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vnum_err := pac_contabilidad.f_traspasar(vcempres, pfecini, pfecfin, pnomfichero,
                                               pfadminini, pfadminfin);

      IF vnum_err <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnum_err);
         RETURN 1;
      --RAISE e_object_error;
      END IF;

      RETURN vnum_err;
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
   END f_traspasar;

   -- 11.0 - 09/10/2014 - MMM - 0033018: 0014809: Generar en modo BATCH la interface de contabilidad - Inicio
   /*************************************************************************
      Función que ejecuta el map 321 en modo batch
      param in  pcempres : código empresa
      param out  pnomfichero : Nombre fichero
   *************************************************************************/
   FUNCTION f_traspasar_batch(
      pcempres IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pfadminini IN DATE,
      pfadminfin IN DATE,
      pnomfichero OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000) := 'pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_traspasar_batch';
      vnum_err       NUMBER := 0;
      vcempres       NUMBER;
      vidioma        NUMBER;
      vsproces       NUMBER;
      v_plsql        VARCHAR2(4000);
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma;
      vpasexec := 10;
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vnum_err := 0;
      vpasexec := 10;
      vnum_err := f_procesini(f_user, pcempres, 'TRASPASO_CONTAB', 'Traspaso', vsproces);
      COMMIT;
      vnum_err := NULL;

      BEGIN
         vpasexec := 20;

         SELECT COUNT(1)
           INTO vnum_err
           FROM user_jobs
          WHERE UPPER(what) LIKE '%F_TRASPASAR%';

         vpasexec := 30;

         IF vnum_err > 0 THEN
            -- Ya existe un proceso de informe activo
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9905165);
            RAISE e_object_error;
         END IF;

         vpasexec := 40;
         v_plsql :=
            'DECLARE num_err NUMBER; pnomfichero VARCHAR2(200); mensajes t_iax_mensajes; v_salida NUMBER; begin '
            || CHR(10) || 'num_err:= pac_contexto.f_inicializarctx(' || CHR(39) || f_user
            || CHR(39) || ');' || CHR(10) || 'v_salida := pac_md_contabilidad.f_traspasar('
            || pcempres || ',
                    to_date(''' || TO_CHAR(pfecini, 'DD/MM/YYYY')
            || ''',''DD/MM/YYYY''),
                    to_date(''' || TO_CHAR(pfecfin, 'DD/MM/YYYY')
            || ''',''DD/MM/YYYY''),
                    to_date(''' || TO_CHAR(pfadminini, 'DD/MM/YYYY')
            || ''',''DD/MM/YYYY''),
                    to_date(''' || TO_CHAR(pfadminfin, 'DD/MM/YYYY')
            || ''',''DD/MM/YYYY''),
                    pnomfichero, mensajes);' || CHR(10) || ' end;';
         vpasexec := 50;
         vnum_err := pac_jobs.f_ejecuta_job(NULL, v_plsql, NULL);
         vpasexec := 60;

         IF vnum_err > 0 THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ' men=' || vnum_err);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, vnum_err);
            RETURN 1;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam || ' men=' || vnum_err,
                        SQLCODE || ' ' || SQLERRM);
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            RETURN 1;
      END;

      IF vsproces IS NOT NULL THEN
         -- Proceso diferido
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0,
                                              f_axis_literales(9904687, vidioma) || ' '
                                              || vsproces);
      END IF;

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
   END f_traspasar_batch;

   -- 11.0 - 09/10/2014 - MMM - 0033018: 0014809: Generar en modo BATCH la interface de contabilidad - Inicio

   --Bug.: 0014782  - JMF - 09/09/2010
   /*************************************************************************
       Función que monta el fichero con los filtros de busqueda y devuelve el fichero mostrado
      param in  pcempres : código empresa
      param in  pfcontabini : fecha de contabilidad inicial
      param in  pfcontabfin : fecha de contabilidad final
      param in  pftraspasini : fecha de traspaso inicial
      param in  pftraspasfin : fecha de traspaso inicial
      param in  pchecktraspas : traspasados o no
      param out  pnomfichero : Nombre fichero
    *************************************************************************/
   FUNCTION f_montar_fichero(
      pcempres IN NUMBER,
      pfcontabini IN DATE,
      pfcontabfin IN DATE,
      pftraspasini IN DATE,
      pftraspasfin IN DATE,
      pfadminini IN DATE,
      pfadminfin IN DATE,
      pchecktraspas IN NUMBER,
      pnomfichero OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'pcempres=' || pcempres || ', pfcontabini=' || pfcontabini || ', pfcontabfin='
            || pfcontabfin || ', pftraspasini=' || pftraspasini || ', pftraspasfin='
            || pftraspasfin || ', pfadminini=' || pfadminini || ', pfadminfin=' || pfadminfin
            || ', pchecktraspas=' || pchecktraspas;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_montar_fichero';
      vnum_err       NUMBER(1) := 0;
      vcempres       NUMBER;
   BEGIN
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      pac_contabilidad.p_montar_fichero(vcempres, pfcontabini, pfcontabfin, pftraspasini,
                                        pftraspasfin, pfadminini, pfadminfin, pchecktraspas,
                                        pac_md_common.f_get_cxtidioma, pnomfichero);

      IF pnomfichero IS NULL THEN
         RAISE e_object_error;
      END IF;

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
   END f_montar_fichero;

   --Bug.: 0014782  - ICV - 09/09/2010
   /*************************************************************************
      Función que devuelve un sys_refcursor con los registros detallados de la contabilidad diaria filtrado por los parametros
      del modelo del parámetro
      param in  pcempres : código empresa
      param in  pfcontab : fecha de contabilidad
      param in  pccuenta : Cuenta
      pnlinea in : linea
      psmodcon in : smodcon
      pcpais in : Código País
      pfefeadm : Fefeadm
      pcproces : Código Proceso
      param out  pdetcontab : Cursor con los resultados
      param in out MENSAJES  : mensajes de error
   *************************************************************************/
   FUNCTION f_get_detcontabilidad_diaria(
      pcempres IN NUMBER,
      pfcontab IN DATE,
      pccuenta IN VARCHAR2,
      pnlinea IN NUMBER,
      psmodcon IN NUMBER,
      pcpais IN NUMBER,
      pfefeadm IN DATE,
      pcproces IN NUMBER,
      pdetcontab OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(3000)
         := 'pcempres=' || pcempres || ', pfcontab=' || pfcontab || ', pccuenta=' || pccuenta
            || ', pnlinea =' || pnlinea || ', psmodcon = ' || psmodcon || ', pcpais = '
            || pcpais || ', pfefeadm = ' || pfefeadm || ', pcproces = ' || pcproces;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_get_detcontabilidad_diaria';
      vnum_err       NUMBER(1) := 0;
      vquery         VARCHAR2(32000);
      vcempres       NUMBER;
   BEGIN
      vcempres := pcempres;

      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      vquery := pac_cuadre_adm.f_contabiliza_detallediario(vcempres, pfcontab, pccuenta,
                                                           pnlinea, psmodcon, pcpais, pfefeadm,
                                                           pcproces);
      pdetcontab := pac_md_listvalores.f_opencursor(vquery, mensajes);
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
   END f_get_detcontabilidad_diaria;

--Fin Bug.: 0014782
 /*************************************************************************
      Función que selecciona info sobre el desglose de los apuntes manuales.
         param in PCEMPRES    : código empresa
         param in PFCONTA_INI      : fecha contable inicial
         param in PFCONTA_FIN      : fecha contable final
         param in PFEFEADM_INI     : fecha adm inicial
         param in PFEFEADM_FIN     : fecha adm final
         param in out MENSAJES : mensajes de error
      *************************************************************************/
   FUNCTION f_get_apuntesmanuales(
      pcempres IN NUMBER,
      pfconta_ini IN DATE,
      pfconta_fin IN DATE,
      pfefeadm_ini IN DATE,
      pfefeadm_fin IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300)
         := 'pcempres=' || pcempres || ', pfconta_ini=' || TO_CHAR(pfconta_ini, 'DD/MM/YYYY')
            || ', pfconta_fin=' || TO_CHAR(pfconta_fin, 'DD/MM/YYYY') || ', pfefeadm_ini='
            || TO_CHAR(pfefeadm_ini, 'DD/MM/YYYY') || ', pfefeadm_fin='
            || TO_CHAR(pfefeadm_fin, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_get_apuntesmanuales';
      vsquery        VARCHAR2(32000);
      cur            sys_refcursor;
      vmaxreg        NUMBER;
   BEGIN
      -- Busquem el pais
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CONTAB_ONLINE'), 0) = 1 THEN
         vsquery :=
            'SELECT fconta, nasient, tatribu tasient, ccuenta, ccoletilla, tapunte, iapunte, tdescri,
       fefeadm, cenlace, otros cproces, sinterf, ttippag, idpago, null cpais, nlinea
  FROM contab_manu_interf c, detvalores d
 WHERE c.nasient = d.catribu
    AND d.cvalor = 132
    AND d.cidioma = '
            || pac_md_common.f_get_cxtidioma;
      ELSE
         vsquery :=
            'Select  fconta, nasient, tatribu tasient, ccuenta, null coletilla, tapunte, iapunte, tdescri,
    fefeadm, cenlace, cproces, null sinterf, null ttippag, null idpago, cpais, nlinea
from contab_manu_dia c, detvalores d
 WHERE c.nasient = d.catribu
 AND d.cvalor = 132
   AND d.cidioma = '
            || pac_md_common.f_get_cxtidioma;
      END IF;

      IF pfconta_ini IS NOT NULL THEN
         vsquery := vsquery || ' and fconta >= to_date(''' || TO_CHAR(pfconta_ini, 'ddmmyyyy')
                    || ''',''ddmmyyyy'')';
      END IF;

      IF pfconta_fin IS NOT NULL THEN
         vsquery := vsquery || ' and fconta <= to_date(''' || TO_CHAR(pfconta_fin, 'ddmmyyyy')
                    || ''',''ddmmyyyy'')';
      END IF;

      IF pfefeadm_ini IS NOT NULL THEN
         vsquery := vsquery || ' and fefeadm >= to_date('''
                    || TO_CHAR(pfefeadm_ini, 'ddmmyyyy') || ''',''ddmmyyyy'')';
      END IF;

      IF pfefeadm_fin IS NOT NULL THEN
         vsquery := vsquery || ' and fefeadm <= to_date('''
                    || TO_CHAR(pfefeadm_fin, 'ddmmyyyy') || ''',''ddmmyyyy'')';
      END IF;

      vmaxreg := pac_parametros.f_parinstalacion_n('N_MAX_REG');

      IF vmaxreg IS NOT NULL THEN
         vsquery := vsquery || ' and rownum <= ' || vmaxreg;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
   END f_get_apuntesmanuales;

    /*************************************************************************
      Función que borra un apunte manual
      CPAIS, FEFEADM, CPROCES, CCUENTA, NLINEA, NASIENT, CEMPRES, FCONTA, TDESCRI, SINTERF, TTIPPAG, IDPAGO, CCOLETILLA, OTROS
      param in P_EMPRESA    : código empresa
      param in P_SMODCON    : cod.de plantilla contable
      param in P_NLINEA     : número de línea
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_del_apuntemanual(
      pcpais IN NUMBER,
      pfefeadm IN DATE,
      pcproces IN NUMBER,
      pccuenta IN VARCHAR2,
      pnlinea IN NUMBER,
      pnasient IN NUMBER,
      pcempres IN NUMBER,
      pfconta IN DATE,
      ptdescri IN VARCHAR2,
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pccoletilla IN VARCHAR2,
      potros IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcpais=' || pcpais || ', pfefeadm=' || pfefeadm || ',pcproces=' || pcproces
            || ',pccuenta=' || pccuenta || ',pnlinea=' || pnlinea || ',pnasient=' || pnasient
            || ',PCEMPRES=' || pcempres || ',PFCONTA=' || pfconta || ',PTDESCRI=' || ptdescri
            || ',PSINTERF=' || psinterf || ',PTTIPPAG=' || pttippag || ',PIDPAGO=' || pidpago
            || ',PCCOLETILLA=' || pccoletilla || ',POTROS=' || potros;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_del_apuntemanual';
      v_error        NUMBER;
      vcempres       NUMBER;
   BEGIN
      vcempres := pcempres;

      IF vcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      v_error := pac_contabilidad.f_del_apuntemanual(pcpais, pfefeadm, pcproces, pccuenta,
                                                     pnlinea, pnasient, vcempres, pfconta,
                                                     ptdescri, psinterf, pttippag, pidpago,
                                                     pccoletilla, potros);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, v_error, vpasexec, vparam);
         RETURN 1;
      END IF;

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
   END f_del_apuntemanual;

   /*************************************************************************
      Función que selecciona info sobre el desglose de los apuntes.
         param in PCEMPRES    : código empresa
         param in PFCONTA_INI      : fecha contable inicial
         param in PFCONTA_FIN      : fecha contable final
         param in PFEFEADM_INI     : fecha adm inicial
         param in PFEFEADM_FIN     : fecha adm final
         param in out MENSAJES : mensajes de error
      *************************************************************************/
   FUNCTION f_get_apuntes(
      pcempres IN VARCHAR2,
      pfconta_ini IN DATE,
      pfconta_fin IN DATE,
      pfefeadm_ini IN DATE,
      pfefeadm_fin IN DATE,
      pidpago IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(300)
         := 'pcempres=' || pcempres || ', pfconta_ini=' || TO_CHAR(pfconta_ini, 'DD/MM/YYYY')
            || ', pfconta_fin=' || TO_CHAR(pfconta_fin, 'DD/MM/YYYY') || ', pfefeadm_ini='
            || TO_CHAR(pfefeadm_ini, 'DD/MM/YYYY') || ', pfefeadm_fin='
            || TO_CHAR(pfefeadm_fin, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_get_apuntes';
      vsquery        VARCHAR2(32000);
      cur            sys_refcursor;
      v_nmax         NUMBER := 1000;
      vsquery_compta VARCHAR2(32000);
      v_quants       NUMBER;
      vmaxreg        NUMBER;
   BEGIN
      -- Busquem el pais
      IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CONTAB_ONLINE'), 0) = 1 THEN
         vsquery :=
            'SELECT fconta, nasient, tatribu tasient, ccuenta, ccoletilla, tapunte, iapunte, tdescri,
       fefeadm, cenlace, null cproces, sinterf, ttippag, idpago, null cpais, nlinea, otros,
       null claveasi, null ftraspaso, null fasiento, null tipodiario, tlibro
  FROM contab_asient_interf c, detvalores d
 WHERE c.nasient = d.catribu
 AND d.cvalor = 132
 AND d.cidioma = '
            || pac_md_common.f_get_cxtidioma;

         IF pidpago IS NOT NULL THEN
            vsquery := vsquery || ' and c.idpago = ' || pidpago;
         END IF;
      ELSE
         vsquery :=
            'Select  fconta, nasient, tatribu tasient, ccuenta, null coletilla, tapunte, iapunte, tdescri,
    fefeadm, cenlace, cproces, null sinterf, null ttippag, null idpago, cpais, nlinea, null otros,
    claveasi, ftraspaso, fasiento, tipodiario, null tlibro
from contab_asient_dia c, detvalores d
 WHERE c.nasient = d.catribu
 AND d.cvalor = 132
   AND d.cidioma = '
            || pac_md_common.f_get_cxtidioma;
      END IF;

      IF pfconta_ini IS NOT NULL THEN
         vsquery := vsquery || ' and fconta >= to_date(''' || TO_CHAR(pfconta_ini, 'ddmmyyyy')
                    || ''',''ddmmyyyy'')';
      END IF;

      IF pfconta_fin IS NOT NULL THEN
         vsquery := vsquery || ' and fconta <= to_date(''' || TO_CHAR(pfconta_fin, 'ddmmyyyy')
                    || ''',''ddmmyyyy'')';
      END IF;

      IF pfefeadm_ini IS NOT NULL THEN
         vsquery := vsquery || ' and fefeadm >= to_date('''
                    || TO_CHAR(pfefeadm_ini, 'ddmmyyyy') || ''',''ddmmyyyy'')';
      END IF;

      IF pfefeadm_fin IS NOT NULL THEN
         vsquery := vsquery || ' and fefeadm <= to_date('''
                    || TO_CHAR(pfefeadm_fin, 'ddmmyyyy') || ''',''ddmmyyyy'')';
      END IF;

      vmaxreg := pac_parametros.f_parinstalacion_n('N_MAX_REG');

      IF vmaxreg IS NOT NULL THEN
         vsquery := vsquery || ' and rownum <= ' || vmaxreg;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
   END f_get_apuntes;

    /*************************************************************************
      Función que inserta un apunte manual
      CPAIS, FEFEADM, CPROCES, CCUENTA, NLINEA, NASIENT, CEMPRES, FCONTA, TDESCRI, SINTERF, TTIPPAG, IDPAGO, CCOLETILLA, OTROS
      param in P_EMPRESA    : código empresa
      param in P_SMODCON    : cod.de plantilla contable
      param in P_NLINEA     : número de línea
      param in out MENSAJES : mensajes de error
   *************************************************************************/
   FUNCTION f_set_apuntemanual(
      psinterf IN NUMBER,
      pttippag IN NUMBER,
      pidpago IN NUMBER,
      pfconta IN DATE,
      pnasient IN NUMBER,
      pnlinea IN NUMBER,
      pccuenta IN VARCHAR2,
      pccoletilla IN VARCHAR2,
      ptapunte IN VARCHAR2,
      piapunte IN NUMBER,
      ptdescri IN VARCHAR2,
      pfefeadm IN DATE,
      potros IN VARCHAR2,
      pcenlace IN VARCHAR2,
      pcempres IN NUMBER,
      pcproces IN NUMBER,
      pcpais IN NUMBER,
      pftraspaso IN DATE,
      pclaveasi IN VARCHAR2,
      ptipodiario IN VARCHAR2,
      pfasiento IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psinterf=' || psinterf || ', pttippag=' || pttippag || ',pidpago=' || pidpago
            || ',pfconta=' || pfconta || ',pnlinea=' || pnlinea || ',pnasient=' || pnasient
            || ',pccuenta=' || pccuenta || ',pccoletilla=' || pccoletilla || ',ptapunte='
            || ptapunte || ',piapunte=' || piapunte || ',ptdescri=' || ptdescri
            || ',pfefeadm=' || pfefeadm || ',potros=' || potros || ',pcenlace=' || pcenlace
            || ',pcempres=' || pcempres || ',pcproces=' || pcproces || ',pcpais=' || pcpais
            || ',pftraspaso=' || pftraspaso || ',pclaveasi=' || pclaveasi || ',ptipodiario='
            || ptipodiario || ',pfasiento=' || pfasiento;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_set_apuntemanual';
      v_error        NUMBER;
      vcempres       NUMBER;
   BEGIN
      vcempres := pcempres;

      IF vcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa;
      END IF;

      v_error := pac_contabilidad.f_set_apuntemanual(psinterf, pttippag, pidpago, pfconta,
                                                     pnasient, pnlinea, pccuenta, pccoletilla,
                                                     ptapunte, piapunte, ptdescri, pfefeadm,
                                                     potros, pcenlace, vcempres, pcproces,
                                                     pcpais, pftraspaso, pclaveasi,
                                                     ptipodiario, pfasiento);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, v_error, vpasexec, vparam);
         RETURN 1;
      END IF;

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
   END f_set_apuntemanual;

   /*************************************************************************
         Función que traspasa un apunte manual a las tablas de apuntes reales.
         param in PCEMPRES    : código empresa
         param in PFCONTA_INI      : fecha contable inicial
         param in PFCONTA_FIN      : fecha contable final
         param in PFEFEADM_INI     : fecha adm inicial
         param in PFEFEADM_FIN     : fecha adm final
         param in out MENSAJES : mensajes de error
      *************************************************************************/
   FUNCTION f_traspasa_apuntemanual(mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vparam         VARCHAR2(200) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTABILIDAD.f_traspasa_apuntemanual';
      v_error        NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vsumd          NUMBER;
      vsumh          NUMBER;
      vsinterf       NUMBER;
      v_interficie   VARCHAR2(100);
      vtipopago      NUMBER := 20;
      vlineaini      VARCHAR2(500);
      vresultado     NUMBER(10);
      vnerror        NUMBER(10);
      vnumerr        NUMBER(10);
      vidpago        NUMBER;
      vterminal      NUMBER;
      perror         VARCHAR2(2000);
   BEGIN
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'CONTAB_ONLINE'),
             0) = 1 THEN
         BEGIN
            SELECT SUM(sumd), SUM(sumh)
              INTO vsumd, vsumh
              FROM (SELECT SUM(iapunte) sumd, 0 sumh
                      FROM contab_manu_interf
                     WHERE tapunte = 'D'
                    UNION ALL
                    SELECT 0 sumd, SUM(iapunte) sumh
                      FROM contab_manu_interf
                     WHERE tapunte = 'H') suma;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_error := 9905405;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
               RETURN v_error;
         END;

         IF (vsumd - vsumh) <> 0
            OR(vsumd + vsumh) = 0 THEN
            v_error := 9905405;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
            RETURN v_error;
         END IF;

         vpasexec := 2;

         IF vsinterf IS NULL THEN
            pac_int_online.p_inicializar_sinterf;
            vsinterf := pac_int_online.f_obtener_sinterf;
         END IF;

         BEGIN
            INSERT INTO contab_asient_interf
                        (sinterf, ttippag, idpago, fconta, nasient, nlinea, ccuenta,
                         ccoletilla, tapunte, iapunte, tdescri, fefeadm, otros, cenlace,
                         tlibro, cmanual)
               (SELECT vsinterf, ttippag, idpago, fconta, nasient, nlinea, ccuenta,
                       ccoletilla, tapunte, iapunte, tdescri, fefeadm, otros, cenlace, tlibro,
                       1
                  FROM contab_manu_interf);
         EXCEPTION
            WHEN OTHERS THEN
               v_error := 103869;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 103869);
               RETURN v_error;
         END;

         vpasexec := 3;

         SELECT   idpago, ttippag
             INTO vidpago, vtipopago
             FROM contab_asient_interf
            WHERE sinterf = vsinterf
              AND cmanual = 1
         GROUP BY idpago, ttippag;

         vpasexec := 4;
         v_interficie := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                       'INTERFICIE_ERP');   --Bug.: 19887
         vlineaini := pac_md_common.f_get_cxtempresa || '|' || vtipopago || '|' || 1 || '|'
                      || vidpago || '|' || NULL || '|' || vterminal || '|' || f_user || '|'
                      || NULL || '|' || NULL || '|' || NULL || '|' || NULL;
         vresultado := pac_int_online.f_int(pac_md_common.f_get_cxtempresa, vsinterf,
                                            v_interficie, vlineaini);
         vpasexec := 5;

         DELETE FROM contab_manu_interf;

         vpasexec := 6;

         BEGIN
            -- Recupero el error
            SELECT r1.cresultado, r1.terror, r1.nerror
              INTO vresultado, perror, vnerror
              FROM int_resultado r1
             WHERE r1.sinterf = vsinterf
               AND r1.smapead = (SELECT MAX(r2.smapead)
                                   FROM int_resultado r2
                                  WHERE r2.sinterf = vsinterf);
         EXCEPTION
            WHEN OTHERS THEN
               vresultado := NULL;
               perror := NULL;
               vnerror := NULL;
         END;

         vpasexec := 7;

         IF (NVL(vresultado, 1) <> 0
             OR NVL(vnerror, 1) <> 0) THEN
            vnumerr := pac_con.f_cont_reproceso(vsinterf, 2);
         ELSIF NVL(vresultado, 1) = 0 THEN
            vnumerr := pac_con.f_cont_reproceso(vsinterf, 1);
         END IF;

         vpasexec := 8;

         IF vresultado <> 0
            OR TRIM(perror) IS NOT NULL THEN
            IF vresultado = 0 THEN
               vresultado := 9903116;   --151323;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresultado, perror);
               RETURN vresultado;
            END IF;

            p_tab_error(f_sysdate, f_user, 'pac_md_contabilidad.f_traspasa_apunte_manual',
                        vpasexec, 'error no controlado', perror || ' ' || vnerror);
         --Mira si borraar sin_tramita_movpago porque se tiene que hacer un commit para que loo vea el sap
         -- RETURN verror;--ETM
         END IF;
      ELSE
         BEGIN
            SELECT SUM(sumd), SUM(sumh)
              INTO vsumd, vsumh
              FROM (SELECT SUM(iapunte) sumd, 0 sumh
                      FROM contab_manu_dia
                     WHERE tapunte = 'D'
                    UNION ALL
                    SELECT 0 sumd, SUM(iapunte) sumh
                      FROM contab_manu_dia
                     WHERE tapunte = 'H') suma;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_error := 9905405;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
               RETURN v_error;
         END;

         IF (vsumd - vsumh) <> 0
            OR(vsumd + vsumh) = 0 THEN
            v_error := 9905405;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
            RETURN v_error;
         END IF;

         vpasexec := 9;

         BEGIN
            INSERT INTO contab_asient_dia
                        (cempres, fconta, nasient, nlinea, ccuenta, cproces, fefeadm, cpais,
                         tapunte, iapunte, tdescri, ftraspaso, cenlace, claveasi, tipodiario,
                         fasiento, cmanual)
               (SELECT cempres, fconta, nasient, nlinea, ccuenta, cproces, fefeadm, cpais,
                       tapunte, iapunte, tdescri, NULL, cenlace, claveasi, tipodiario,
                       fasiento, 1
                  FROM contab_manu_dia);
         EXCEPTION
            WHEN OTHERS THEN
               v_error := 103869;
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 103869);
               RETURN v_error;
         END;

         vpasexec := 10;

         DELETE FROM contab_manu_dia;
      END IF;

      IF v_error = 0 THEN
         --v_error := 9905405;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 111313);
         RETURN v_error;
      END IF;

      RETURN v_error;
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
   END f_traspasa_apuntemanual;
END pac_md_contabilidad;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CONTABILIDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CONTABILIDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CONTABILIDAD" TO "PROGRAMADORESCSI";
