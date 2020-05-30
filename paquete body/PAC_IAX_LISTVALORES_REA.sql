--------------------------------------------------------
--  DDL for Package Body PAC_IAX_LISTVALORES_REA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_LISTVALORES_REA" AS
/******************************************************************************
 NOMBRE: PAC_IAX_LISTVALORES_REA
 PROPOSITO: Funciones para recuperar valores

 REVISIONES:
 Ver Fecha Autor Descripcion
 --------- ---------- --------------- ------------------------------------
 1.0                                  1. Creacion del Package
 2.0       07/10/2011 APD             2. 0019602: LCOL_A002-Correcciones en las pantallas de mantenimiento del reaseguro
 3.0       23/05/2012 AVT             3. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
 4.0       22/08/2013 DEV             4. 0026443: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 76 -XL capacidad prioridad dependiente del producto (Fase3)
 5.0       30/09/2013 RCL             5. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
 6.0       09/04/2014 AGG             6. 0026663: POSPG400-(POSPG400)- Parametrizacion Reaseguro, Coaseguro - Parametrizacion contratos
 7.0       22/09/2014 MMM             7. 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales
 8.0       02/09/2016 HRE             8. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
   Recupera los tipos de tramos proporcionales, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos_prop(ctiprea NUMBER,mensajes OUT t_iax_mensajes)--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona ctiprea
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.f_get_tipostramos_prop';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_tipostramos_prop(ctiprea, mensajes);--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona ctiprea
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipostramos_prop;

   /*************************************************************************
   Recupera los tipos de tramos NO proporcionales, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos_noprop(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.f_get_tipostramos_noprop';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_tipostramos_noprop(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipostramos_noprop;

   /*************************************************************************
   Recupera los tipos de E/R cartera de primas, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_ercarteraprimas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_ercarteraprimas';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_ercarteraprimas(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ercarteraprimas;

   /*************************************************************************
   Recupera las base de calculo de la prima XL, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_basexl(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_basexl';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_basexl(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_basexl;

   /*************************************************************************
   Recupera el campo de aplicacion de la tasa, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_aplictasa(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_aplictasa';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_aplictasa(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_aplictasa;

   /*************************************************************************
   Recupera los tipos de tasa, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipotasa(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_tipotasa';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_tipotasa(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipotasa;

   /*************************************************************************
   Recupera los tipos de comision, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipocomision(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_tipocomision';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_tipocomision(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipocomision;

   /*************************************************************************
   Recupera los tramos de comision, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tramosrea(pctipo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' pctipo = ' || pctipo;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_tramosrea';
   BEGIN
      --Comprovacio de parametres d'entrada
      IF pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_rea.f_get_tramosrea(pctipo, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tramosrea;

   /*************************************************************************
   Recupera los contratos de proteccion, devuelve un SYS_REFCURSOR
   param in pcempres: codigo de la empresa
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_contratoprot(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' pcempres = ' || pcempres;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_contratoprot';
      vcempres       NUMBER;
   BEGIN
      --Comprovacio de parametres d'entrada
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa();
      --RAISE e_param_error;
      ELSE
         vcempres := pcempres;
      END IF;

      cur := pac_md_listvalores_rea.f_get_contratoprot(vcempres, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_contratoprot;

   /*************************************************************************
   Recupera las versiones (tabla CONTRATOS) de un contrato, devuelve un SYS_REFCURSOR
   param in pcempres: codigo de la empresa
   param in pscontra: codigo del contrato
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_versionescontratoprot(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
                                  := ' pcempres = ' || pcempres || '; pscontra = ' || pscontra;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_versionescontratoprot';
      vcempres       NUMBER;
   BEGIN
      --Comprovacio de parametres d'entrada
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa();
      --RAISE e_param_error;
      ELSE
         vcempres := pcempres;
      END IF;

      IF pscontra IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_rea.f_get_versionescontratoprot(vcempres, pscontra, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_versionescontratoprot;

   /*************************************************************************
   Recupera los tipos de prima XL, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipoprimaxl(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_tipoprimaxl';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_tipoprimaxl(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipoprimaxl;

   /*************************************************************************
   Recupera las reposiciones, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_reposiciones(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_reposiciones';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_reposiciones(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_reposiciones;

   /*************************************************************************
   Recupera los tipos de clausulas / tramos escalonados, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipoclautramescal(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_tipoclautramescal';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_tipoclautramescal(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipoclautramescal;

   /*************************************************************************
   Recupera los contratos (tabla CODICONTRATOS), devuelve un SYS_REFCURSOR
   param in pcempres: codigo de la empresa
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   -- 7.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Inicio
   --FUNCTION f_get_contratos(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
   FUNCTION f_get_contratos(
      pcempres IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pctipo IN NUMBER DEFAULT -1)
      -- 7.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Fin
   RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' pcempres = ' || pcempres;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_contratos';
      vcempres       NUMBER;
   BEGIN
      --Comprovacio de parametres d'entrada
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa();
      --RAISE e_param_error;
      ELSE
         vcempres := pcempres;
      END IF;

      -- 7.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Inicio
      cur := pac_md_listvalores_rea.f_get_contratos(vcempres, mensajes, pctipo);
      --cur := pac_md_listvalores_rea.f_get_contratos(vcempres, mensajes);
      -- 7.0 - 22/09/2014 - MMM - 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales - Fin
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_contratos;

   /*************************************************************************
   Recupera las versiones (tabla CONTRATOS), devuelve un SYS_REFCURSOR
   param in pcempres: codigo de la empresa
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_versiones(pcempres IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' pcempres = ' || pcempres;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.F_Get_versiones';
      vcempres       NUMBER;
   BEGIN
      --Comprovacio de parametres d'entrada
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa();
      --RAISE e_param_error;
      ELSE
         vcempres := pcempres;
      END IF;

      cur := pac_md_listvalores_rea.f_get_versiones(vcempres, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_versiones;

   /*************************************************************************
   Recupera los brokers (tabla COMPANIAS), devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_broker(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);   -- := ' p_cversion = ' || p_cversion;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.f_get_broker';
   BEGIN
      --Comprovacio de parametres d'entrada
/*
      IF p_cversion IS NULL THEN
         RAISE e_param_error;
      END IF;
*/
      cur := pac_md_listvalores_rea.f_get_broker(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_broker;

   /*************************************************************************
   Recupera todos los tipos de tramos (proporcionales y no proporcionales,
   devuelve un SYS_REFCURSOR param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos(pscontra IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' pscontra = ' || pscontra;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.f_get_tipostramos';
   BEGIN
      --Comprovacio de parametres d'entrada
      IF pscontra IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_rea.f_get_tipostramos(pscontra, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipostramos;

   /*************************************************************************
   Recupera todos los tipos de tramos asociados a un contrato y version
   devuelve un SYS_REFCURSOR param out : mensajes de error
   param in pscontra : codigo del contrato
   param in p_nversio : codigo de version
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_tipostramos_fil(
      pscontra IN NUMBER,
      p_nversio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
               := ' scontra = ' || TO_CHAR(pscontra) || ' and nversio = '
                  || TO_CHAR(p_nversio);
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.f_get_tipostramos';
   BEGIN
      --Comprovacio de parametres d'entrada
      IF pscontra IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_rea.f_get_tipostramos_fil(v_param, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipostramos_fil;

   /*************************************************************************
   Recupera la lista de valores del desplegable para el estado de la cuenta
   devuelve un SYS_REFCURSOR param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_estado_cta(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.f_get_estado_cta';
   BEGIN
      cur := pac_md_listvalores_rea.f_get_estado_cta(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_estado_cta;

   /*************************************************************************
        Recupera la lista desplegable de conceptos de la cuenta tecnica del Reaseguro
        param out mensajes : mensajes de error
        return             : ref cursor
     *************************************************************************/
   FUNCTION f_get_tipo_movcta(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.f_get_tipo_movcta';
   BEGIN
      cur := pac_md_listvalores_rea.f_get_tipo_movcta(mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_tipo_movcta;

   /*************************************************************************
      Recupera la lista desplegable de los identificadores de los pagos
      asociados al siniestro
      param in pnsinies: n¿mero del siniestro
      param out mensajes : mensajes de error
      return             : ref cursor     *************************************************************************/
   FUNCTION f_get_identif_pago_sin(pnsinies IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200);
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.f_get_identif_pago_sin';
   BEGIN
      cur := pac_md_listvalores_rea.f_get_identif_pago_sin(pnsinies, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_identif_pago_sin;

    /*************************************************************************
      Recupera la versi¿n vigente de un contrato
      param in pcempres : empresa
      param in pscontra : contrato
      param out : mensajes de error
      return : ref cursor
   *************************************************************************/
   FUNCTION f_get_versionvigente_contrato(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
                                  := ' pcempres = ' || pcempres || '; pscontra = ' || pscontra;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.f_get_versionvigente_contrato';
      vcempres       NUMBER;
   BEGIN
      --Comprovacio de parametres d'entrada
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa();
      ELSE
         vcempres := pcempres;
      END IF;

      IF pscontra IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_rea.f_get_versionvigente_contrato(vcempres, pscontra, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_versionvigente_contrato;

   /*************************************************************************
      Recupera los ramos de un contrato
      param in pcempres : empresa
      param in pscontra : contrato
      param out : mensajes de error
      return : ref cursor
   *************************************************************************/
   FUNCTION f_get_ramos_contrato(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
                                  := ' pcempres = ' || pcempres || '; pscontra = ' || pscontra;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTVALORES_REA.f_get_ramos_contrato';
      vcempres       NUMBER;
   BEGIN
      --Comprovacio de parametres d'entrada
      IF pcempres IS NULL THEN
         vcempres := pac_md_common.f_get_cxtempresa();
      ELSE
         vcempres := pcempres;
      END IF;

      IF pscontra IS NULL THEN
         RAISE e_param_error;
      END IF;

      cur := pac_md_listvalores_rea.f_get_ramos_contrato(vcempres, pscontra, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_ramos_contrato;
END pac_iax_listvalores_rea;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_REA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_REA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTVALORES_REA" TO "PROGRAMADORESCSI";
