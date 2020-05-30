--------------------------------------------------------
--  DDL for Package Body PAC_IAX_ESTCESIONESREA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "AXIS"."PAC_IAX_ESTCESIONESREA" IS
    /****************************************************************************
       NOMBRE:     PAC_MD_ESTCESIONESREA
       PROP¿SITO:  Cesiones Manuales de Reaseguro

       REVISIONES:
       Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  -------- ------------------------------------
      1.0        07/09/2015   XXX     1. Creaci¿n del package.
      2.0        09/02/2016   AGG     0039214: QT:22872: No permite realizar cesion manual
	  3.0       08/12/2019   FEPP    IAXIS-4821 :MODIFICACIONES FACULTATIVAS LA INFORMACION DE FACULTATIVOS NO PASSA A LA TABLA REASEGURO
    ****************************************************************************/

   -- Control de errores
-- 0 - Ok
-- 1 - Error
-- 2 - Warning
   FUNCTION f_del_estcesionesrea(
      pscesrea NUMBER DEFAULT -1,
      pssegpol NUMBER DEFAULT -1,
      psseguro NUMBER DEFAULT -1,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_del_estcesionesrea';
      v_numerr       NUMBER;
   BEGIN
      v_numerr := pac_md_estcesionesrea.f_del_estcesionesrea(pscesrea, pssegpol, psseguro);

      IF (v_numerr != 0) THEN
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, v_numerr, vpasexec, vparam);  -- Esta versi¿n mustra el paquete
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
      ELSE
         COMMIT;
      END IF;

      RETURN v_numerr;
   END f_del_estcesionesrea;

   FUNCTION f_set_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pncesion estcesionesrea.ncesion%TYPE,
      picesion estcesionesrea.icesion%TYPE,
      picapces estcesionesrea.icapces%TYPE,
      psseguro estcesionesrea.sseguro%TYPE,
      pssegpol estcesionesrea.ssegpol%TYPE,
      pnpoliza estcesionesrea.npoliza%TYPE,
      pncertif estcesionesrea.ncertif%TYPE,
      pnversio estcesionesrea.nversio%TYPE,
      pscontra estcesionesrea.scontra%TYPE,
      pctramo estcesionesrea.ctramo%TYPE,
      psfacult estcesionesrea.sfacult%TYPE,
      pnriesgo estcesionesrea.nriesgo%TYPE,
      picomisi estcesionesrea.icomisi%TYPE,
      pscumulo estcesionesrea.scumulo%TYPE,
      pgarant estcesionesrea.cgarant%TYPE,
      pspleno estcesionesrea.spleno%TYPE,
      pnsinies estcesionesrea.nsinies%TYPE,
      pfefecto estcesionesrea.fefecto%TYPE,
      pfvencim estcesionesrea.fvencim%TYPE,
      pfcontab estcesionesrea.fcontab%TYPE,
      ppcesion estcesionesrea.pcesion%TYPE,
      psproces estcesionesrea.sproces%TYPE,
      pcgenera estcesionesrea.cgenera%TYPE,
      pfgenera estcesionesrea.fgenera%TYPE,
      pfregula estcesionesrea.fregula%TYPE,
      pfanulac estcesionesrea.fanulac%TYPE,
      pnmovimi estcesionesrea.nmovimi%TYPE,
      psidepag estcesionesrea.sidepag%TYPE,
      pipritarrea estcesionesrea.ipritarrea%TYPE,
      ppsobreprima estcesionesrea.psobreprima%TYPE,
      pcdetces estcesionesrea.cdetces%TYPE,
      pipleno estcesionesrea.ipleno%TYPE,
      picapaci estcesionesrea.icapaci%TYPE,
      nmovigen estcesionesrea.nmovigen%TYPE,
      piextrap estcesionesrea.iextrap%TYPE,
      iextrea estcesionesrea.iextrea%TYPE,
      pnreemb estcesionesrea.nreemb%TYPE,
      pnfact estcesionesrea.nfact%TYPE,
      pnlinea estcesionesrea.nlinea%TYPE,
      pitarifrea estcesionesrea.itarifrea%TYPE,
      picomext estcesionesrea.icomext%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_set_estcesionesrea';
      v_numerr       NUMBER;
   BEGIN
      v_numerr := pac_md_estcesionesrea.f_set_estcesionesrea(pscesrea, pncesion, picesion,
                                                             picapces, psseguro, pssegpol,
                                                             pnpoliza, pncertif, pnversio,
                                                             pscontra, pctramo, psfacult,
                                                             pnriesgo, picomisi, pscumulo,
                                                             pgarant, pspleno, pnsinies,
                                                             pfefecto, pfvencim, pfcontab,
                                                             ppcesion, psproces, pcgenera,
                                                             pfgenera, pfregula, pfanulac,
                                                             pnmovimi, psidepag, pipritarrea,
                                                             ppsobreprima, pcdetces, pipleno,
                                                             picapaci, nmovigen, piextrap,
                                                             iextrea, pnreemb, pnfact,
                                                             pnlinea, pitarifrea, picomext);

      IF (v_numerr != 0) THEN
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, v_numerr, vpasexec, vparam);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
         ROLLBACK;
      ELSE
         COMMIT;
      END IF;

      RETURN v_numerr;
   END f_set_estcesionesrea;

-------------------------------------------------------------------
-- f_get_estcesionesrea, f_get_estcesionrea
-------------------------------------------------------------------
   FUNCTION f_get_estcesionrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pcgenera NUMBER DEFAULT -1,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_estcesionesrea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_get_estcesionrea';
      vres           ob_iax_estcesionesrea := NULL;
   BEGIN
      vres := pac_md_estcesionesrea.f_get_estcesionrea(pscesrea, pcgenera);

      IF (vres IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120135);
      -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 120135, vpasexec, vparam);
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_estcesionrea;

   FUNCTION f_get_estcesionesrea(
      psseguro IN NUMBER,
      pcgenera IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_estcesionesrea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_get_estcesionesrea';
      vres           t_iax_estcesionesrea := NULL;
   BEGIN
      vres := pac_md_estcesionesrea.f_get_estcesionesrea(psseguro, pcgenera);

      IF (vres IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120135);
      -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 120135, vpasexec, vparam);
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 100001);
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_estcesionesrea;

-------------------------------------------------------------------
-- f_get_sim_estcesionesrea (Bot¿n simulaci¿n)
-------------------------------------------------------------------
   FUNCTION f_get_sim_estcesionesrea(psseguro NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_sim_estcesionesrea IS
      vpasexec       NUMBER(8) := 1;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_get_estcesionesrea';
      vres           t_iax_sim_estcesionesrea := NULL;
   BEGIN
      vres := pac_md_estcesionesrea.f_get_sim_estcesionesrea(psseguro);

      IF (vres IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908558);
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 100001);
         RETURN NULL;
   END f_get_sim_estcesionesrea;

   FUNCTION f_get_reaseguro_xl(psseguro IN seguros.sseguro%TYPE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_get_reaseguro_xl';
      vres           NUMBER;
   BEGIN
      vres := pac_md_estcesionesrea.f_get_reaseguro_xl(psseguro);

      IF (vres != 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1,
                                              pac_md_estcesionesrea.no_se_encontraron_datos);
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 100001);
         RETURN NULL;
   END f_get_reaseguro_xl;

-------------------------------------------------------------------
-- f_get_estcesionesreasinies, f_get_estcesionreasinies
-------------------------------------------------------------------
   FUNCTION f_get_estcesionreasinies(
      pnsinies estcesionesrea.nsinies%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_estcesionesrea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_get_estcesionreasinies';
      vres           ob_iax_estcesionesrea := NULL;
   BEGIN
      vres := pac_md_estcesionesrea.f_get_estcesionreasinies(pnsinies);

      IF (vres IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120135);
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 100001);
         RETURN NULL;
   END f_get_estcesionreasinies;

   FUNCTION f_get_estcesionesreasinies(
      pnsinies estcesionesrea.nsinies%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_estcesionesrea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_get_estcesionesreasinies';
      vres           t_iax_estcesionesrea := NULL;
   BEGIN
      vres := pac_md_estcesionesrea.f_get_estcesionesreasinies(pnsinies);

      IF (vres IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120135);
      -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 120135, vpasexec, vparam);
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 100001);
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_estcesionesreasinies;

-------------------------------------------------------------------
-- f_get_estcesionesreapolizas, f_get_estcesionesreapoliza
-------------------------------------------------------------------
   FUNCTION f_get_estcesionreapolizas(
      pnpoliza estcesionesrea.npoliza%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_estcesionesrea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_get_estcesionreapolizas';
      vres           ob_iax_estcesionesrea := NULL;
   BEGIN
      vres := pac_md_estcesionesrea.f_get_estcesionreapoliza(pnpoliza);

      IF (vres IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120135);
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 100001);
         RETURN NULL;
   END f_get_estcesionreapolizas;

   --INI - AXIS 4105 - 05/06/2019 - AABG - SE AGREGA NUEVO PARAMETRO MOVIMIENTO
   FUNCTION f_get_estcesionesreapolizas(
      pnpoliza estcesionesrea.npoliza%TYPE,
      pcgenera NUMBER,
      pnmovimi NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_estcesionesrea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_get_estcesionesreapolizas';
      vres           t_iax_estcesionesrea := NULL;
   BEGIN
      vres := pac_md_estcesionesrea.f_get_estcesionesreamovpol(pnpoliza, pcgenera, pnmovimi);

      IF (vres IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120135);
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 100001);
         RETURN NULL;
   END f_get_estcesionesreapolizas;
   --FIN - AXIS 4105 - 05/06/2019 - AABG - SE AGREGA NUEVO PARAMETRO MOVIMIENTO

   FUNCTION f_get_estcesionesreacum(
      pscumulo IN NUMBER,
      pcgenera NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_estcesionesrea IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_get_estcesionesreacum';
      vres           t_iax_estcesionesrea := NULL;
   BEGIN
      vres := pac_md_estcesionesrea.f_get_estcesionesreacum(pscumulo, pcgenera);

      IF (vres IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120135);
      -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 120135, vpasexec, vparam);
      END IF;

      RETURN vres;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 100001);
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_estcesionesreacum;

-------------------------------------------------------------------
-- f_update_estcesionesrea
-------------------------------------------------------------------
   FUNCTION f_update_estcesionesrea_tramo(
      pscesrea estcesionesrea.scesrea%TYPE,
      pctramo estcesionesrea.ctramo%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'pscesrea:  ' || pscesrea || ', pctramo: ' || pctramo;
      vobjectname    VARCHAR2(200) := 'pac_iax_estcesionesrea.f_update_estcesionesrea';
      vresult        NUMBER;
   BEGIN

      IF (pscesrea IS NULL
          OR pctramo IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1,
                                              pac_md_estcesionesrea.faltan_parametros);
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, '',
                     f_axis_literales(pac_md_estcesionesrea.faltan_parametros) || ': '
                     || vparam);
         RETURN pac_md_estcesionesrea.faltan_parametros;
      END IF;

      vresult := pac_md_estcesionesrea.f_update_estcesionesrea(pscesrea, pctramo);

      IF (vresult != 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresult);
         ROLLBACK;
      ELSE
         COMMIT;
      END IF;

      RETURN vresult;
   END f_update_estcesionesrea_tramo;

   FUNCTION f_update_estcesionesrea_fechas(
      pscesrea estcesionesrea.scesrea%TYPE,   -- Primary key en estcesionesrea
      pssegpol estcesionesrea.ssegpol%TYPE,   -- Identificador del seguro
      pcgarant estcesionesrea.cgarant%TYPE,   -- Garant¿a
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE,   -- Nueva fecha de vencimiento
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pscesrea:  ' || pscesrea || ', pssegpol: ' || pssegpol || ', pcgarant: '
            || pcgarant || ', pfefecto: ' || pfefecto || ', pfvencimiento: ' || pfvencimiento;
      vobjectname    VARCHAR2(200) := 'pac_iax_estcesionesrea.f_update_estcesionesrea';
      vresult        NUMBER;
   BEGIN

      IF (pscesrea IS NULL
          OR pssegpol IS NULL
          OR pcgarant IS NULL
          OR pfefecto IS NULL
          OR pfvencimiento IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1,
                                              pac_md_estcesionesrea.faltan_parametros);
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, '',
                     f_axis_literales(pac_md_estcesionesrea.faltan_parametros) || ': '
                     || vparam);
         RETURN pac_md_estcesionesrea.faltan_parametros;
      END IF;

      vresult := pac_md_estcesionesrea.f_update_estcesionesrea(pscesrea, pssegpol, pcgarant,
                                                               pfefecto, pfvencimiento);

      IF (vresult != 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresult);
         ROLLBACK;
      ELSE
         COMMIT;
      END IF;

      RETURN vresult;
   END f_update_estcesionesrea_fechas;

   FUNCTION f_update_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pssegpol estcesionesrea.ssegpol%TYPE,
      picesion estcesionesrea.icesion%TYPE,
      picapces estcesionesrea.icapces%TYPE,
      ppcesion estcesionesrea.pcesion%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pscesrea:  ' || pscesrea || ', pssegpol: ' || pssegpol || ', picesion: '
            || picesion || ', picapces: ' || picapces;
      vobjectname    VARCHAR2(200) := 'pac_iax_estcesionesrea.f_update_estcesionesrea';
      vresult        NUMBER;
   BEGIN

      IF (pscesrea IS NULL
          OR pssegpol IS NULL
          OR picesion IS NULL
          OR picapces IS NULL
          OR ppcesion IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1,
                                              pac_md_estcesionesrea.faltan_parametros);
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, '',
                     f_axis_literales(pac_md_estcesionesrea.faltan_parametros) || ': '
                     || vparam);
         RETURN pac_md_estcesionesrea.faltan_parametros;
      END IF;

      vresult := pac_md_estcesionesrea.f_update_estcesionesrea(pscesrea, pssegpol, picesion,
                                                               picapces, ppcesion);

      IF (vresult != 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vresult);
         ROLLBACK;
      ELSE
         COMMIT;
      END IF;

      RETURN vresult;
   END f_update_estcesionesrea;

   FUNCTION setnuevotramocesion(
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE,   -- Nueva fecha de vencimiento
      psseguro estcesionesrea.sseguro%TYPE,   -- Identificador del seguro
      pnmovimi NUMBER,   -- Identificador del movimiento
      psproces NUMBER,   -- Identificador del proceso
      pmoneda monedas.cmoneda%TYPE,
      pnpoliza NUMBER,
      pncertif NUMBER,
      porigen NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.setNuevoTramoCesion';
      vparam         VARCHAR2(1) := NULL;
      v_numerr       NUMBER;
   BEGIN
      v_numerr := pac_md_estcesionesrea.setnuevotramocesion(pfefecto, pfvencimiento, psseguro,
                                                            pnmovimi, psproces, pmoneda,
                                                            pnpoliza, pncertif, porigen);

      IF (v_numerr != 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
      ELSE
         COMMIT;
      END IF;

      RETURN v_numerr;
   END setnuevotramocesion;

   FUNCTION validafechas(
      pscesrea estcesionesrea.scesrea%TYPE,   -- Primary key en estcesionesrea
      pssegpol estcesionesrea.ssegpol%TYPE,   -- Identificador del seguro
      pcgarant estcesionesrea.cgarant%TYPE,   -- Garant¿a
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE,   -- Nueva fecha de vencimiento
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.validaFechas';
      v_numerr       NUMBER;
      vparam         VARCHAR2(1) := NULL;
   BEGIN
      IF (pscesrea IS NULL
          OR pssegpol IS NULL) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1,
                                              pac_md_estcesionesrea.faltan_parametros);
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, '',
                     f_axis_literales(pac_md_estcesionesrea.faltan_parametros) || ': '
                     || vparam);
         RETURN pac_md_estcesionesrea.faltan_parametros;
      END IF;

      v_numerr := pac_md_estcesionesrea.validafechas(pscesrea, pssegpol, pcgarant, pfefecto,
                                                     pfvencimiento);

      IF (v_numerr != 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
      -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, v_numerr, vpasexec, vparam);
      END IF;

      RETURN v_numerr;
   END validafechas;

   FUNCTION compruebaporcenfacultativo(
      pscesrea estcesionesrea.scesrea%TYPE,
      pcesion estcesionesrea.pcesion%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.compruebaPorcenFacultativo';
      v_numerr       NUMBER;
      vparam         VARCHAR2(1) := NULL;
   BEGIN
      RETURN pac_md_estcesionesrea.compruebaporcenfacultativo(pscesrea, pcesion);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120135);
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 120135, vpasexec, vparam);
         RETURN 120135;
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001);
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
         --                                 psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1000001;
   END compruebaporcenfacultativo;

   FUNCTION compruebaporcentajes(
      pssegpol estcesionesrea.ssegpol%TYPE,
      pcgarant estcesionesrea.cgarant%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_numerr       NUMBER := 0;
   BEGIN
      v_numerr := pac_md_estcesionesrea.compruebaporcentajes(pssegpol, pcgarant);

      IF (v_numerr != 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
      END IF;

      RETURN v_numerr;
   END compruebaporcentajes;

   FUNCTION f_cabfacul(pssegpol NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_numerr       NUMBER := 0;
   BEGIN
      v_numerr := pac_md_estcesionesrea.f_cabfacul(pssegpol);

      IF (v_numerr != 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
         ROLLBACK;
      END IF;

      COMMIT;
      RETURN v_numerr;
   END f_cabfacul;

   FUNCTION f_get_totalesestcesionrea(
      psseguro IN NUMBER,
      ptotporcesion OUT NUMBER,
      ptotcapital OUT NUMBER,
      ptotcesion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_get_totalesestcesionrea';
      v_numerr       NUMBER;
      vparam         VARCHAR2(1) := NULL;
   BEGIN
      RETURN pac_md_estcesionesrea.f_get_totalesestcesionrea(psseguro, ptotporcesion,
                                                             ptotcapital, ptotcesion);
   END f_get_totalesestcesionrea;

   FUNCTION traspaso_inf_cesionesreatoest(
      pssegpol NUMBER,
      pnsinies NUMBER,
      pcgenera NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(64) := 'traspaso_inf_cesionesreatoest';
   BEGIN
      pac_md_estcesionesrea.traspaso_inf_cesionesreatoest(pssegpol, NULL, NULL, pnsinies,
                                                          pcgenera);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908417);   -- Error al pasar los datos de CESIONESREA a ESTCESIONESREA
         RETURN 9908417;
   END traspaso_inf_cesionesreatoest;

   FUNCTION traspaso_inf_esttocesionesrea(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(64) := 'f_traspaso_inf_cesionesreatoest';
      vmensaje       VARCHAR2(1000); --CONF-1082
   BEGIN
      pac_md_estcesionesrea.traspaso_inf_esttocesionesrea(psseguro, NULL, NULL, vmensaje);

      IF NVL(vmensaje,'-') != '-' THEN --CONF-1082
        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes,
                                             2,
                                             99,
                                             vmensaje);
      ELSE --CONF-1082
        --INICIO (22872 + 39214): AGG 09/02/2016
        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 101625);
        --FIN (22872 + 39214): AGG 09/02/2016
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9908419);   -- Error al pasar datos de ESTCESIONESREA a CESIONESREA
         RETURN 9908419;
   END traspaso_inf_esttocesionesrea;

   FUNCTION simulacion_cierre_proporcional(
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(64) := 'simulacion_cierre_proporcional';
      vmoneda        NUMBER := pac_monedas.f_moneda_seguro(NULL, psseguro);
      vparam         VARCHAR2(256)
         := 'psseguro: ' || psseguro || ', psproces: ' || psproces || ', pfproces: '
            || pfproces;
   BEGIN
      pac_md_estcesionesrea.simulacion_cierre_proporcional(psseguro, pcerror, psproces,
                                                           pfproces);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 1, NULL, SQLERRM || ': ' || vparam);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1);
         RETURN 1;
   END simulacion_cierre_proporcional;

   FUNCTION simulacion_cierre_xl(
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(64) := 'simulacion_cierre_xl';
      vmoneda        NUMBER := pac_monedas.f_moneda_seguro(NULL, psseguro);
      vparam         VARCHAR2(256)
         := 'psseguro: ' || psseguro || ', psproces: ' || psproces || ', pfproces: '
            || pfproces;
   BEGIN
      pac_md_estcesionesrea.simulacion_cierre_xl(psseguro, pcerror, psproces, pfproces);
      RETURN 0;
   /*EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, 1, NULL, SQLERRM || ': ' || vparam);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1);
         RETURN 1;*/
   END simulacion_cierre_xl;

   FUNCTION f_consulta_ces_man(
      pnpoliza IN seguros.npoliza%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pnrecibo IN NUMBER,
      pfiniefe IN DATE,
      pffinefe IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
   BEGIN
      RETURN pac_md_estcesionesrea.f_consulta_ces_man(pnpoliza, pnsinies, pnrecibo, pfiniefe, pffinefe, mensajes);
   END f_consulta_ces_man;

   FUNCTION f_get_garant_est(
      pssegpol estcesionesrea.sseguro%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
   BEGIN
      RETURN pac_md_estcesionesrea.f_get_garant_est(pssegpol, mensajes);
   END f_get_garant_est;

   FUNCTION f_estado_de_poliza(
      psseguro NUMBER,
      pnpoliza NUMBER,
      pestado OUT VARCHAR2,
      pfestado OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_numerr       NUMBER := 0;
   BEGIN
      v_numerr := f_estado_poliza(psseguro, pnpoliza, f_sysdate, pestado, pfestado);

      IF (v_numerr != 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
      END IF;

      RETURN v_numerr;
   END f_estado_de_poliza;

   FUNCTION f_detvalores_tramos(psseguro IN seguros.sseguro%TYPE, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'psseguro =' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_ESTCESIONESREA.f_detvalores_tramos';
   BEGIN
      cur := pac_md_estcesionesrea.f_detvalores_tramos(psseguro, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_detvalores_tramos;

   FUNCTION f_valida_tramos(pssegpol NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_numerr       NUMBER := 0;
   BEGIN
      v_numerr := pac_md_estcesionesrea.f_valida_tramos(pssegpol);

      IF (v_numerr != 0) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_numerr);
      END IF;

      RETURN v_numerr;
   END f_valida_tramos;
   
  END pac_iax_estcesionesrea;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_ESTCESIONESREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ESTCESIONESREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ESTCESIONESREA" TO "PROGRAMADORESCSI";
