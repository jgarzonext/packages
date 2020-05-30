--------------------------------------------------------
--  DDL for Package Body PAC_MD_CONVENIOS_EMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CONVENIOS_EMP" IS
         /******************************************************************************
      --      NOMBRE:       PAC_MD_CONVENIOS_EMP
            PROPOSITO: Tratamiento convenios en capa presentación

            REVISIONES:
            Ver        Fecha        Autor             Descripcion
            ---------  ----------  ---------------  ------------------------------------
            1.0        04/02/2015   JRH                1. Creacion del package.
         2.0        22/06/2015   CJMR               2. 36397/208377: PRB. Ajuste consulta de movimiento del suplemento de regularización
   *****************************************************************************/
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;
   vg_idioma      NUMBER := pac_md_common.f_get_cxtidioma;
   vpmode         VARCHAR2(3);
   vsolicit       NUMBER;
   vnmovimi       NUMBER;

/***********************************************************************
      Devuelve  los tramos de regularización para la consulta de detalle de  movimiento
         param in psseguro  : Número interno de seguro
       param in pnmovimi  : Número interno de pnmovimi
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_tramosregul(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro: ' || psseguro || ', pnmovimi: ' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.f_get_tramosregul';
      cur            sys_refcursor;
      squery         VARCHAR2(2000);
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      squery :=
         '  SELECT   t.sseguro, t.nmovimi, t.nmovimiorg, t.fecini, t.fecfin, t.ctipo, ff_desvalorfijo(8001009,pac_md_common.f_get_cxtidioma,t.ctipo) ttipo, r.nrecibo, v.itotalr,
         SUM(t.iprianuorg) iprianuorg, SUM(t.iprianufin) iprianufin, SUM(t.icapitalorg) icapitalorg, SUM(t.icapitalfin) icapitalfin
    FROM tramosregul t, recibos r, vdetrecibos v, movseguro m
   WHERE t.sseguro = '
         || psseguro || 'AND t.nmovimi = ' || pnmovimi
         || 'AND r.sseguro = t.sseguro
     AND t.nmovimiorg = r.nmovimi
     AND r.sseguro = m.sseguro
     and t.nmovimi = m.nmovimi
     AND ((m.cmotmov = 601 AND t.fecfin = r.fefecto) or (m.cmotmov <> 601 AND t.fecini = r.fefecto))
     AND r.nrecibo = v.nrecibo
GROUP BY t.sseguro, t.nmovimi, t.nmovimiorg, t.fecini, t.fecfin, t.ctipo, r.nrecibo, v.itotalr
ORDER BY 1, 2, 3, 4 ';
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_get_tramosregul;

   /***********************************************************************
      Devuelve  los datos del suplemento de regularización
         param in psseguro  : Número interno de seguro
       param in pnmovimi  : Número interno de pnmovimi
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_datos_sup_regul(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro: ' || psseguro || ', pnmovimi: ' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.f_datos_sup_regul';
      cur            sys_refcursor;
      squery         VARCHAR2(2000);
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      squery :=
         ' SELECT   nriesgo, SUM(naseg1) naseg1, SUM(naseg2) naseg2, SUM(naseg3) naseg3,
         SUM(naseg4) naseg4, SUM(naseg5) naseg5, SUM(naseg6) naseg6, SUM(naseg7) naseg7,
         SUM(naseg8) naseg8, SUM(naseg9) naseg9, SUM(naseg10) naseg10, SUM(naseg11) naseg11,
         SUM(naseg12) naseg12
    FROM (SELECT nriesgo, DECODE(nmes, 1, naseg, 0) naseg1, DECODE(nmes, 2, naseg, 0) naseg2,
                 DECODE(nmes, 3, naseg, 0) naseg3, DECODE(nmes, 4, naseg, 0) naseg4,
                 DECODE(nmes, 5, naseg, 0) naseg5, DECODE(nmes, 6, naseg, 0) naseg6,
                 DECODE(nmes, 7, naseg, 0) naseg7, DECODE(nmes, 8, naseg, 0) naseg8,
                 DECODE(nmes, 9, naseg, 0) naseg9, DECODE(nmes, 10, naseg, 0) naseg10,
                 DECODE(nmes, 11, naseg, 0) naseg11, DECODE(nmes, 12, naseg, 0) naseg12
            FROM aseguradosmes WHERE sseguro = '
         || psseguro || ' AND nmovimi = ' || pnmovimi || ' )
GROUP BY nriesgo';
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_datos_sup_regul;

   /***********************************************************************
      Devuelve  los ámbitos de convenios para el producto
         param in psproduc  :  Producto
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_lstambitos(
      psproduc IN NUMBER,
      pdescri IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psproduc: ' || psproduc || ', pdescri: ' || pdescri;
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.f_get_lstambitos';
      cur            sys_refcursor;
      squery         VARCHAR2(2000);
   BEGIN
      -- IF psproduc IS NULL THEN
      --    RAISE e_param_error;
      -- END IF;
      vpasexec := 2;
      squery :=
         ' select PROVINCIAS.CPROVIN cprovin,
        PROVINCIAS.TPROVIN tprovin
        FROM
        PROVINCIAS
        WHERE
        PROVINCIAS.CPAIS =   nvl(f_parproductos_v('
         || psproduc
         || ', ''PAIS_PROD''),f_parinstalacion_n(''PAIS_DEF''))
        AND UPPER(PROVINCIAS.TPROVIN) like UPPER(''%'
         || pdescri || '%'') order by 2';
      vpasexec := 3;
      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);
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
   END f_get_lstambitos;

   /***********************************************************************
      Devuelve  los convenios activos para el producto
         param in psproduc  :  Producto
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_lstconvempvers(
      psproduc IN NUMBER,
      pprovin IN NUMBER,
      pdescri IN VARCHAR2,
      ptcodconv IN VARCHAR2 DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_convempvers IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psproduc: ' || psproduc || ', pprovin: ' || pprovin;
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.f_get_lstconvempvers';
      vvers          t_iax_convempvers;
      vtipousuario   NUMBER := 1;
      vcrealiza      NUMBER;

      CURSOR cur_cconvenios IS
         SELECT   c.idconv, c.tcodconv, c.cestado, c.cperfil, v.cvida, c.corganismo,
                  c.tdescri || '-' || p.tprovin || '-' || ca.tccaa || '-' || pa.tpais tdescri,
                  v.nversion, c.cprovin, c.ccaa, c.cpais, v.idversion, v.cestado cestadovers,
                  v.tobserv
             FROM cnv_conv_emp c, cnv_conv_emp_vers v, provincias p, ccaas ca, paises pa
            WHERE c.idconv = v.idconv(+)
              AND p.cprovin(+) = c.cprovin
              AND ca.idccaa(+) = c.ccaa
              AND pa.cpais(+) = c.cpais
              AND UPPER(c.tdescri) LIKE UPPER('%' || pdescri || '%')
              AND c.cestado = 1
              AND v.cestado(+) = 1
              AND((c.cprovin IS NOT NULL
                   AND c.cprovin = pprovin)
                  OR(c.cprovin IS NULL))
              AND((c.ccaa IS NOT NULL
                   AND c.ccaa IN(SELECT pr.idccaa
                                   FROM provincias pr
                                  WHERE pr.cprovin = pprovin))
                  OR(c.ccaa IS NULL))
              AND c.cpais = (SELECT cpais
                               FROM provincias
                              WHERE cprovin = pprovin)
              AND(ptcodconv IS NULL
                  OR c.tcodconv LIKE UPPER(ptcodconv))
         ORDER BY NVL(c.cprovin, 0), NVL(c.ccaa, 0), c.tdescri;
   BEGIN
      IF pprovin IS NULL THEN
         RAISE e_param_error;
      END IF;

      vtipousuario :=
         pac_cfg.f_get_user_accion_permitida
                        (f_user, 'TODOS_CONVENIOS', 0,
                         pac_iax_produccion.poliza.det_poliza.cempres,   -- BUG9981:DRA:06/05/2009
                         vcrealiza);
      --JRH IMP Comprobaar que solo hayuna versión por convenio?
      vvers := t_iax_convempvers();

      FOR reg IN cur_cconvenios LOOP
         IF reg.cperfil = 2
            AND vtipousuario = 0 THEN   --Convenio no visible para agentes
            NULL;
         ELSE
            vvers.EXTEND;
            vvers(vvers.LAST) := ob_iax_convempvers();
            vvers(vvers.LAST).idversion := reg.idversion;   --   Identificador  de Convenio / Versión actual de la póliza (tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).idconv := reg.idconv;   --   Identificador  de Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).tcodconv := reg.tcodconv;   --   Código de Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).cestado := reg.cestado;   -- Estado de convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).cperfil := reg.cperfil;   -- Perfil de convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).tdescri := reg.tdescri;   --   Descripción de Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).corganismo := reg.corganismo;   --  Organismo del Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).cvida := reg.cvida;   --  Organismo del Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).nversion := reg.nversion;   --  Número de Versión (Tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).cestadovers := reg.cestadovers;   --  Estado de dicha Versión (Tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).nversion_ant := NULL;   -- Número de Versión Movimiento Anterior( para mostrar en suplementos Tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).testado := NULL;   --  Detvalores por idioma usuario de CESTADO del convenio.
            vvers(vvers.LAST).tperfil := NULL;   --  Detvalores por idioma usuario de CPERFIL.
            vvers(vvers.LAST).torganismo := NULL;   --   Detvalores por idioma usuario de CORGANISMO.
            vvers(vvers.LAST).testadovers := NULL;   --    Detvalores por idioma usuario de CESTADOVERS de la versión.
            vvers(vvers.LAST).tvida := NULL;   --Detvalores por idioma usuario de CVIDA de la versión.
            vvers(vvers.LAST).tobserv := reg.tobserv;
         END IF;
      END LOOP;

--JRH IMP Pendiente descripción
      vpasexec := 2;
      RETURN vvers;
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
   END f_get_lstconvempvers;

   /***********************************************************************
      Devuelve  los datos de una versión
         param in psproduc  :  psseguro  pidversion  pmodo
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_datosconvempvers(
      psseguro IN NUMBER,
      pidversion IN NUMBER,
      pmodo IN VARCHAR2,
      pidconv OUT NUMBER,
      ptcodconv OUT VARCHAR2,
      ptdescri OUT VARCHAR2,
      pcestado OUT NUMBER,
      pcperfil OUT NUMBER,
      pcvida OUT NUMBER,
      pcorganismo OUT NUMBER,
      pnversion OUT NUMBER,
      pcestadovers OUT NUMBER,
      pnversion_ant OUT NUMBER,
      pobserv OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'PSSEGURO: ' || psseguro || ', PIDVERSION: ' || pidversion || ', PMODO: ' || pmodo;
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.F_GET_DATOSCONVEMPVERS';
      vnumerr        NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pidversion IS NULL
         OR pmodo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_convenios_emp.f_get_datosconvempvers(psseguro, pidversion, pmodo, pidconv,
                                                          ptcodconv, ptdescri, pcestado,
                                                          pcperfil, pcvida, pcorganismo,
                                                          pnversion, pcestadovers,
                                                          pnversion_ant, pobserv);

      IF vnumerr <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobject, 191,
                     'psseguro = ' || psseguro || ' pidversion = ' || pidversion
                     || ' pmodo = ' || pmodo,
                     vnumerr);
         RETURN 1;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, 2,
                     'psseguro = ' || psseguro || ' pidversion = ' || pidversion
                     || ' pmodo = ' || pmodo,
                     1);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobject, 3,
                     'psseguro = ' || psseguro || ' pidversion = ' || pidversion
                     || ' pmodo = ' || pmodo,
                     1);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 4,
                     'psseguro = ' || psseguro || ' pidversion = ' || pidversion
                     || ' pmodo = ' || pmodo || ' ' || SQLERRM,
                     1);
         RETURN 1;
   END f_get_datosconvempvers;

   /***********************************************************************
      Devuelve  los datos de una versión
         param in psproduc  :  psseguro  pidversion  pmodo
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_versioncon(psseguro IN NUMBER, pidversion IN NUMBER, pmodo IN VARCHAR2)
      RETURN ob_iax_convempvers IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'PSSEGURO: ' || psseguro || ', PIDVERSION: ' || pidversion || ', PMODO: ' || pmodo;
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.f_get_versioncon';
      vnumerr        NUMBER;
      vversion       ob_iax_convempvers;
      vidconv        NUMBER;
      vtcodconv      VARCHAR2(20);
      vtdescri       VARCHAR2(200);
      vcestado       NUMBER;
      vcperfil       NUMBER;
      vcvida         NUMBER;
      vcorganismo    NUMBER;
      vnversion      NUMBER;
      vcestadovers   NUMBER;
      vnversion_ant  NUMBER;
      vtobserv       VARCHAR2(2000);
   BEGIN
      IF psseguro IS NULL
         OR pidversion IS NULL
         OR pmodo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := f_get_datosconvempvers(psseguro, pidversion, pmodo, vidconv, vtcodconv,
                                        vtdescri, vcestado, vcperfil, vcvida, vcorganismo,
                                        vnversion, vcestadovers, vnversion_ant, vtobserv);
      vpasexec := 3;

      IF vnumerr <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobject, 191,
                     'psseguro = ' || psseguro || ' pidversion = ' || pidversion
                     || ' pmodo = ' || pmodo,
                     vnumerr);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      vversion := ob_iax_convempvers();
      vversion.idversion := pidversion;
      vversion.idconv := vidconv;
      vversion.tcodconv := vtcodconv;
      vversion.cestado := vcestado;   -- Estado de convenio (Tabla CNV_CONV_EMP)
      vversion.cperfil := vcperfil;   -- Perfil de convenio (Tabla CNV_CONV_EMP)
      vversion.tdescri := vtdescri;
      vversion.corganismo := vcorganismo;   --  Organismo del Convenio (Tabla CNV_CONV_EMP)
      vversion.cvida := vcvida;   --  Organismo del Convenio (Tabla CNV_CONV_EMP)
      vversion.nversion := vnversion;   --  Número de Versión (Tabla CNV_CONV_EMP_VERS)
      vversion.cestadovers := vcestadovers;   --  Estado de dicha Versión (Tabla CNV_CONV_EMP_VERS)
      vversion.nversion_ant := vnversion_ant;   --  NUMBER   ,-- Número de Versión Movimiento Anterior( para mostrar en suplementos Tabla CNV_CONV_EMP_VERS)
--JRH IMP Faltan las descripciónes perfil CROSS
      vversion.testado := ff_desvalorfijo(8001001, pac_md_common.f_get_cxtidioma(),
                                          vversion.cestado);
--vversion.TPERFIL :=ff_desvalorfijo(672, pac_md_common.f_get_cxtidioma(), ctipide);
      vversion.torganismo := ff_desvalorfijo(8001000, pac_md_common.f_get_cxtidioma(),
                                             vversion.corganismo);
      vversion.testadovers := ff_desvalorfijo(8001004, pac_md_common.f_get_cxtidioma(),
                                              vversion.cestadovers);
      vversion.tvida := ff_desvalorfijo(8001002, pac_md_common.f_get_cxtidioma(),
                                        vversion.cvida);
      vversion.tobserv := vtobserv;
      vpasexec := 5;
      RETURN vversion;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, 2,
                     'psseguro = ' || psseguro || ' pidversion = ' || pidversion
                     || ' pmodo = ' || pmodo,
                     1);
         RAISE;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobject, 3,
                     'psseguro = ' || psseguro || ' pidversion = ' || pidversion
                     || ' pmodo = ' || pmodo,
                     1);
         RAISE;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 4,
                     'psseguro = ' || psseguro || ' pidversion = ' || pidversion
                     || ' pmodo = ' || pmodo || ' ' || SQLERRM,
                     1);
         RAISE;
   END f_get_versioncon;

     /***********************************************************************
      Devuelve  la versión activa del convenio de una póliza y su  fecha
      param in psproduc  :  psseguro
      param out pidversion  :  Id de la versión
      param out pfefecto  :  Fecha
      mensajes : mensajes de error
      return             : number
   ***********************************************************************/
   FUNCTION f_get_versactivaconv(pidconv IN NUMBER, pidversion OUT NUMBER, pfefecto OUT DATE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'pidconv: ' || pidconv;
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.F_GET_VERSACTIVACONV';
      vnumerr        NUMBER;
      lnversion      cnv_conv_emp_vers.nversion%TYPE;   -- N. versión
   BEGIN
      IF pidconv IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vnumerr := pac_convenios_emp.f_get_versactivaconv(pidconv, pidversion, pfefecto,
                                                        lnversion);

      IF vnumerr <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobject, 0, 'pidconv = ' || pidconv, vnumerr);
         RETURN 1;
      END IF;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobject, 2, 'pidconv = ' || pidconv, 1);
         RETURN 1;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobject, 3, 'pidconv = ' || pidconv, 1);
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 4,
                     'pidconv = ' || pidconv || '  ' || SQLERRM, 1);
         RETURN 1;
   END f_get_versactivaconv;

   /******************************************************************
       F_ES_PRODUCTOCONVENIOS: Obtener si el producto es de convenios
       Devuelve:  1 - Si es convenios
               nnnn - No es de convenios (msj de error)
   *******************************************************************/
   FUNCTION f_es_productoconvenios(psproduc IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - psproduc: ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_CONVENIOS_EMP.F_ES_PRODUCTOCONVENIOS';
      lcagrpro       seguros.cagrpro%TYPE;
      ltexto         VARCHAR2(100);
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
   BEGIN
      --

      --
      RETURN pac_convenios_emp.f_es_productoconvenios(psproduc);
   --
   EXCEPTION
      WHEN OTHERS THEN
         ltexto := f_axis_literales(108190, lcidioma);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     ltexto || ' ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 108190;   -- Error general
   END f_es_productoconvenios;

   /******************************************************************
       F_GET_CONVCONTRATABLE: Indica si un convenio es contratable
       Devuelve:
   *******************************************************************/
   FUNCTION f_get_convcontratable(pvers IN ob_iax_convempvers, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'param - psseguro: ' || 'NULL';
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.F_GET_CONVCONTRATABLE';
      num_err        NUMBER;
      ltexto         VARCHAR2(100);
      lcidioma       NUMBER := pac_md_common.f_get_cxtidioma;
      vnerr          NUMBER;
      vesaviso       NUMBER;
   BEGIN
      --
      vnerr :=
         pac_convenios_emp.f_get_convcontratable
                                                (pvers,
                                                 pac_iax_produccion.poliza.det_poliza.cempres,
                                                 vesaviso);

      IF vnerr <> 0 THEN
         IF vesaviso = 1 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnerr);
            RETURN 0;
         ELSE
            --pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, vnerr, vpasexec, vparam);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, vnerr); -- BUG 0040564 - FAL - 11/02/2016
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   --
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
   END f_get_convcontratable;

   FUNCTION f_proceso_camb_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                               := 'param - Convenio: ' || ptcodconv || ' Idioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.F_PROCESO_CAMB_VERSCON';
      num_err        NUMBER;
      vesaviso       NUMBER;
   BEGIN
      --
      num_err := pac_convenios_emp.f_proceso_camb_verscon(ptcodconv, pcidioma, psproces);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, num_err, vpasexec, vparam,
                                           ' ' || f_axis_literales(9000493, pcidioma) || ':'
                                           || psproces);
         RETURN 1;
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam,
                                           ' ' || f_axis_literales(9000493, pcidioma) || ':'
                                           || psproces);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam,
                                           ' ' || f_axis_literales(9000493, pcidioma) || ':'
                                           || psproces);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           ' ' || f_axis_literales(9000493, pcidioma) || ':'
                                           || psproces,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_proceso_camb_verscon;

   FUNCTION f_proceso_anul_verscon(
      ptcodconv IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                               := 'param - Convenio: ' || ptcodconv || ' Idioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.F_PROCESO_ANUL_VERSCON';
      num_err        NUMBER;
      vesaviso       NUMBER;
   BEGIN
      --
      num_err := pac_convenios_emp.f_proceso_anul_verscon(ptcodconv, pcidioma, psproces);

      IF num_err <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, num_err, vpasexec, vparam,
                                           ' ' || f_axis_literales(9000493, pcidioma) || ':'
                                           || psproces);
         RETURN 1;
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam,
                                           ' ' || f_axis_literales(9000493, pcidioma) || ':'
                                           || psproces);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam,
                                           ' ' || f_axis_literales(9000493, pcidioma) || ':'
                                           || psproces);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           ' ' || f_axis_literales(9000493, pcidioma) || ':'
                                           || psproces,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_proceso_anul_verscon;

   /******************************************************************
       F_ES_PRODUCTOCONVENIOS: Obtener si el producto es de convenios
       Devuelve:  1 - Si es convenios
               nnnn - No es de convenios (msj de error)
   *******************************************************************/
   FUNCTION f_get_asegurados_innom(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnombre IN VARCHAR2,
      pnmovimi IN VARCHAR2,
      pfecha IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      squery         VARCHAR2(3000);
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.F_GET_ASEGURADOS_INNOM';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
	  --bug 38517-217932 KJSC se modifica para que el nombre del asegurado se pueda buscar por mayúsculas y minúsculas.
      vpnombre          VARCHAR2(1000);
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL THEN
         RAISE e_param_error;
      END IF;

      squery := 'SELECT ROWNUM num,a.norden orden, a.nif nif, a.nombre '
                || q'[||' '|| a.apellidos nombres,]';
      squery :=
         squery
         || ' (SELECT tatribu FROM detvalores v WHERE cidioma = pac_md_common.f_get_cxtidioma () AND cvalor = 11 AND catribu = a.csexo) sexo,a.fnacim fnacim';
      squery := squery || ' FROM asegurados_innom a  WHERE a.sseguro = ' || psseguro
                || ' AND a.nriesgo = ' || pnriesgo;
      vpasexec := 2;

      IF pnombre IS NOT NULL THEN
      --squery := squery || ' and a.nombre || '' '' ||  a.apellidos  like  ''%' || pnombre || '%''';
      --bug 38517-217932 KJSC se modifica para que el nombre del asegurado se pueda buscar por mayúsculas y minúsculas.
         vpnombre := pnombre;
         vpnombre := REPLACE(vpnombre, CHR(39), CHR(39) || CHR(39));
         squery := squery || ' and UPPER(a.nombre) || '' '' ||  UPPER(a.apellidos) LIKE UPPER(''' || '%' || vpnombre || '%' || ''')';
      END IF;

      vpasexec := 3;

      IF pfecha IS NOT NULL THEN
         squery := squery || ' AND a.FALTA < ' || pfecha;
      ELSIF pfecha IS NULL THEN
         squery := squery || ' AND A.FBAJA IS NULL';
      END IF;

      vpasexec := 4;

      IF pnmovimi IS NOT NULL THEN
         squery :=
            squery
            || ' AND nmovimi IN(SELECT MAX(b.nmovimi) FROM ASEGURADOS_INNOM b WHERE b.nmovimi <= '
            || pnmovimi || ' AND b.sseguro = ' || psseguro || ' )';
      ELSIF pnmovimi IS NULL THEN
         squery :=
            squery
            || ' AND nmovimi IN(SELECT MAX(b.nmovimi) FROM ASEGURADOS_INNOM b WHERE b.sseguro = '
            || psseguro || ' )';
      END IF;

      vpasexec := 5;
      cur := pac_md_listvalores.f_opencursor(squery, mensajes);
      vpasexec := 6;
      RETURN cur;
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
   END f_get_asegurados_innom;

         /***********************************************************************
      Devuelve  los convenios activos para el producto
         param in psproduc  :  Producto
       param in pdescri  :  Descripción
                mensajes : mensajes de error
      return             : number
      Bug 34461-210152 KJSC Por medio de email enviado el 28/07/2015 de Jordi Vidal se crea nueva funcion
   ***********************************************************************/
   FUNCTION f_get_lstconvemp(
      psproduc IN NUMBER,
      pprovin IN NUMBER,
      pdescri IN VARCHAR2,
      ptcodconv IN VARCHAR2 DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_convempvers IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psproduc: ' || psproduc || ', pprovin: ' || pprovin || 'pdescri: ' || pdescri
            || ', ptcodconv: ' || ptcodconv;
      vobject        VARCHAR2(200) := 'PAC_MD_CONVENIOS_EMP.f_get_lstconvemp';
      vvers          t_iax_convempvers;
      vtipousuario   NUMBER := 1;
      vcrealiza      NUMBER;
      total          NUMBER := 0;

      CURSOR cur_cconvenios IS
         SELECT   c.idconv, c.tcodconv, c.cestado, c.cperfil, v.cvida, c.corganismo,
                  c.tdescri || '-' || p.tprovin || '-' || ca.tccaa || '-' || pa.tpais tdescri,
                  v.nversion, c.cprovin, c.ccaa, c.cpais, v.idversion, v.cestado cestadovers,
                  v.tobserv
             FROM cnv_conv_emp c, cnv_conv_emp_vers v, provincias p, ccaas ca, paises pa
            WHERE c.idconv = v.idconv(+)
              AND p.cprovin(+) = c.cprovin
              AND ca.idccaa(+) = c.ccaa
              AND pa.cpais(+) = c.cpais
              AND UPPER(c.tdescri) LIKE UPPER('%' || pdescri || '%')
              AND c.cestado = 1
              AND v.cestado(+) = 1
              AND((c.cprovin IS NOT NULL
                   AND c.cprovin = pprovin)
                  OR(c.cprovin IS NULL))
              AND((c.ccaa IS NOT NULL
                   AND c.ccaa IN(SELECT pr.idccaa
                                   FROM provincias pr
                                  WHERE pr.cprovin = pprovin))
                  OR(c.ccaa IS NULL))
              AND c.cpais = (SELECT cpais
                               FROM provincias
                              WHERE cprovin = pprovin)
              AND(ptcodconv IS NULL
                  OR c.tcodconv LIKE UPPER(ptcodconv))
         ORDER BY NVL(c.cprovin, 0), NVL(c.ccaa, 0), c.tdescri;

      --BUG 34461-210152 KJSC no sea obligatorio el ambito
      CURSOR cur_cconvenios1 IS
         SELECT   c.idconv, c.tcodconv, c.cestado, c.cperfil, v.cvida, c.corganismo,
                  c.tdescri || '-' || p.tprovin || '-' || ca.tccaa || '-' || pa.tpais tdescri,
                  v.nversion, c.cprovin, c.ccaa, c.cpais, v.idversion, v.cestado cestadovers,
                  v.tobserv
             FROM cnv_conv_emp c, cnv_conv_emp_vers v, provincias p, ccaas ca, paises pa
            WHERE c.idconv = v.idconv(+)
              AND p.cprovin(+) = c.cprovin
              AND ca.idccaa(+) = c.ccaa
              AND pa.cpais(+) = c.cpais
              AND UPPER(c.tdescri) LIKE UPPER('%' || pdescri || '%')
              AND c.cestado = 1
              AND v.cestado(+) = 1
              AND(ptcodconv IS NULL
                  OR c.tcodconv LIKE UPPER(ptcodconv))
         ORDER BY NVL(c.cprovin, 0), NVL(c.ccaa, 0), c.tdescri;
   BEGIN
      vvers := t_iax_convempvers();

      IF pprovin IS NOT NULL THEN
         FOR reg IN cur_cconvenios LOOP
            SELECT COUNT(*)
              INTO total
              FROM cnv_conv_emp cce, cnv_conv_emp_vers ccev, cnv_conv_emp_seg cces, seguros s
             WHERE cce.idconv = reg.idconv
               AND ccev.idconv = cce.idconv
               AND cces.nmovimi = (SELECT MAX(nmovimi)
                                     FROM cnv_conv_emp_seg
                                    WHERE sseguro = cces.sseguro)
               AND ccev.idversion = cces.idversion
               AND cces.sseguro = s.sseguro
               AND s.csituac NOT IN(2, 3)
               AND cces.idversion <>
                         TO_NUMBER(pac_convenios_emp.f_get_versactivaconv_selet(cce.idconv, 1));

            vvers.EXTEND;
            vvers(vvers.LAST) := ob_iax_convempvers();
            vvers(vvers.LAST).idversion := reg.idversion;   -- Identificador  de Convenio / Versión actual de la póliza (tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).idconv := reg.idconv;   -- Identificador  de Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).tcodconv := reg.tcodconv;   -- Código de Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).cestado := reg.cestado;   -- Estado de convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).cperfil := reg.cperfil;   -- Perfil de convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).tdescri := reg.tdescri;   -- Descripción de Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).corganismo := reg.corganismo;   -- Organismo del Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).cvida := reg.cvida;   -- Organismo del Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).nversion := reg.nversion;   -- Número de Versión (Tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).cestadovers := reg.cestadovers;   -- Estado de dicha Versión (Tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).nversion_ant := NULL;   -- Número de Versión Movimiento Anterior( para mostrar en suplementos Tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).testado := NULL;   -- Detvalores por idioma usuario de CESTADO del convenio.
            vvers(vvers.LAST).tperfil := NULL;   -- Detvalores por idioma usuario de CPERFIL.
            vvers(vvers.LAST).torganismo := NULL;   -- Detvalores por idioma usuario de CORGANISMO.
            vvers(vvers.LAST).testadovers := NULL;   -- Detvalores por idioma usuario de CESTADOVERS de la versión.
            vvers(vvers.LAST).tvida := NULL;   -- Detvalores por idioma usuario de CVIDA de la versión.
            vvers(vvers.LAST).tobserv := reg.tobserv;   -- Observaciones
            vvers(vvers.LAST).cpoliza := total;   -- Total
         END LOOP;
      ELSE
         FOR reg IN cur_cconvenios1 LOOP
            SELECT COUNT(*)
              INTO total
              FROM cnv_conv_emp cce, cnv_conv_emp_vers ccev, cnv_conv_emp_seg cces, seguros s
             WHERE cce.idconv = reg.idconv
               AND ccev.idconv = cce.idconv
               AND cces.nmovimi = (SELECT MAX(nmovimi)
                                     FROM cnv_conv_emp_seg
                                    WHERE sseguro = cces.sseguro)
               AND ccev.idversion = cces.idversion
               AND cces.sseguro = s.sseguro
               AND s.csituac NOT IN(2, 3)
               AND cces.idversion <>
                         TO_NUMBER(pac_convenios_emp.f_get_versactivaconv_selet(cce.idconv, 1));

            vvers.EXTEND;
            vvers(vvers.LAST) := ob_iax_convempvers();
            vvers(vvers.LAST).idversion := reg.idversion;   -- Identificador  de Convenio / Versión actual de la póliza (tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).idconv := reg.idconv;   -- Identificador  de Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).tcodconv := reg.tcodconv;   -- Código de Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).cestado := reg.cestado;   -- Estado de convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).cperfil := reg.cperfil;   -- Perfil de convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).tdescri := reg.tdescri;   -- Descripción de Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).corganismo := reg.corganismo;   -- Organismo del Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).cvida := reg.cvida;   -- Organismo del Convenio (Tabla CNV_CONV_EMP)
            vvers(vvers.LAST).nversion := reg.nversion;   -- Número de Versión (Tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).cestadovers := reg.cestadovers;   -- Estado de dicha Versión (Tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).nversion_ant := NULL;   -- Número de Versión Movimiento Anterior( para mostrar en suplementos Tabla CNV_CONV_EMP_VERS)
            vvers(vvers.LAST).testado := NULL;   -- Detvalores por idioma usuario de CESTADO del convenio.
            vvers(vvers.LAST).tperfil := NULL;   -- Detvalores por idioma usuario de CPERFIL.
            vvers(vvers.LAST).torganismo := NULL;   -- Detvalores por idioma usuario de CORGANISMO.
            vvers(vvers.LAST).testadovers := NULL;   -- Detvalores por idioma usuario de CESTADOVERS de la versión.
            vvers(vvers.LAST).tvida := NULL;   -- Detvalores por idioma usuario de CVIDA de la versión.
            vvers(vvers.LAST).tobserv := reg.tobserv;   -- Observaciones
            vvers(vvers.LAST).cpoliza := total;   -- Total
         END LOOP;
      END IF;

      vpasexec := 2;
      RETURN vvers;
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
   END f_get_lstconvemp;
END pac_md_convenios_emp;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CONVENIOS_EMP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CONVENIOS_EMP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CONVENIOS_EMP" TO "PROGRAMADORESCSI";
