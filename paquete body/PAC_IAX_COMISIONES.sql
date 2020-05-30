--------------------------------------------------------
--  DDL for Package Body PAC_IAX_COMISIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_COMISIONES" IS

   /******************************************************************************
      NOMBRE:     PAC_IAX_COMISIONES
      PROPÓSITO:  Funciones de cuadros de comisiones

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        21/07/2010   AMC               1. Creación del package.
      2.0        14/09/2010   ICV               2. 0015137: MDP Desarrollo de Cuadro Comisiones
      3.0        12/09/2011   JTS               3. 19316: CRT - Adaptar pantalla de comisiones
      4.0        21/05/2015   VCG               4. 033977-204336: MSV: Creación de funciones
	  5.0        22/01/2019   ACL         		5. TCS_2 Se crean las funciones f_valida_cuadro y f_anular_cuadro.
	  6.0        22/01/2019   ACL               6. TCS_2 Se agrega llamado a la funcion f_valida_cuadro desde f_set_cuadrocomision.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*************************************************************************
      Recupera un cuadro de comisiones
      param in pccomisi   : codigo de comision
      param in ptcomisi   : descripcion del cuadro
      param in pctipo     : codigo de tipo
      param in pcestado   : codigo de estado
      param in pffechaini : fecha inicio
      param in pffechafin : fecha fin
      param out pcuadros  : cuadros de comision
      param out mensajes  : mensajes de error
      return              : codigo de error
   *************************************************************************/

	FUNCTION f_get_cuadroscomision(
			pccomisi	IN	NUMBER,
			ptcomisi	IN	VARCHAR2,
			pctipo	IN	NUMBER,
			pcestado	IN	NUMBER,
			pffechaini	IN	DATE,
			pffechafin	IN	DATE,
			pcuadros	OUT	T_IAX_CUADROCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(4000):='PCCOMISI:'
	                         || pccomisi
	                         || ' PTCOMISI:'
	                         || ptcomisi
	                         || ' PCTIPO:'
	                         || pctipo
	                         || ' PCESTADO:'
	                         || pcestado
	                         || ' PFFECHAINI:'
	                         || pffechaini
	                         || ' PFFECHAFIN:'
	                         || pffechafin;
	  vobject  VARCHAR2(200):='PAC_MD_COMISIONES.f_get_cuadroscomision';
	  verror   NUMBER;
	BEGIN
	    verror:=pac_md_comisiones.f_get_cuadroscomision(pccomisi, ptcomisi, pctipo, pcestado, pffechaini, pffechafin, pcuadros, mensajes);

	    IF verror<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_get_cuadroscomision;

	/*************************************************************************

	   param in pccomisi   : codigo de comision
	   param in pcidioma     : codigo de idioma
	   param in ptcomisi   : descripcion del cuadro
	   param out mensajes  : mesajes de error

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_set_obj_desccuadro(
			pcidioma	IN	NUMBER,
			pccomisi	IN	NUMBER,
			ptcomisi	IN	VARCHAR2,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_set_obj_desccuadro';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  trobat      BOOLEAN:=FALSE;
	BEGIN
	    IF pccomisi IS NOT NULL THEN
	      vpasexec:=2;

	      IF obcomision IS NOT NULL THEN
	        IF obcomision.descripciones IS NOT NULL AND
	           obcomision.descripciones.count>0 THEN
	          vpasexec:=3;

	          FOR i IN obcomision.descripciones.first .. obcomision.descripciones.last LOOP
	              IF obcomision.descripciones(i).ccomisi=pccomisi AND
	                 obcomision.descripciones(i).cidioma=pcidioma THEN
	                obcomision.descripciones(i).tcomisi:=ptcomisi;

	                trobat:=TRUE;
	              END IF;
	          END LOOP;

	          vpasexec:=4;

	          IF trobat=FALSE THEN
	            obcomision.descripciones.extend;

	            obcomision.descripciones(obcomision.descripciones.last):=ob_iax_desccuadrocomision ();

	            vpasexec:=5;

	            vnumerr:=pac_md_comisiones.f_set_obj_desccuadro (pccomisi, pcidioma, ptcomisi, obcomision.descripciones(obcomision.descripciones.last), mensajes);

	            vpasexec:=6;

	            IF vnumerr<>0 THEN
	              RAISE e_object_error;
	            END IF;
	          END IF;
	        END IF;
	      ELSE
	        vpasexec:=7;

	        obcomision:=ob_iax_cuadrocomision();

	        obcomision.ccomisi:=1; /*nextval ccomisi seq;*/

	        obcomision.tcomisi:=ptcomisi;

	        obcomision.descripciones:=t_iax_desccuadrocomision();

	        vpasexec:=77;

	        obcomision.descripciones.extend;

	        obcomision.descripciones(obcomision.descripciones.last):=ob_iax_desccuadrocomision ();

	        /* obcomision.descripciones (0) := ob_iax_desccuadrocomision ();*/
	        vpasexec:=8;

	        vnumerr:=pac_md_comisiones.f_set_obj_desccuadro (pccomisi, pcidioma, ptcomisi, obcomision.descripciones(obcomision.descripciones.last), mensajes);

	        IF vnumerr<>0 THEN
	          RAISE e_object_error;
	        END IF;
	      END IF;
	    ELSE
	      RAISE e_param_error;
	    END IF;

	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             ROLLBACK;

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_set_obj_desccuadro;

	/*************************************************************************

	   param in pccomisi   : codigo de comision
	   param in pctipo     : codigo de tipo
	   param in pcestado   : codigo de estado
	   param in pfinivig   : fecha inicio vigencia
	   param in pffinvig   : fecha fin vigencia
	   param in pmodo      : codigo de modo
	   param out mensajes  : mesajes de error

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_set_obj_cuadrocomision(
			pccomisi	IN	NUMBER,
			pctipo	IN	NUMBER,
			pcestado	IN	NUMBER,
			pfinivig	IN	DATE,
			pffinvig	IN	DATE,
			pmodo	IN	VARCHAR2,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_set_obj_cuadrocomision';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  trobat      BOOLEAN:=FALSE;
	  vcestado    NUMBER;
	BEGIN
	    IF obcomision IS NULL  OR
	       obcomision.descripciones IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*validaciones*/
	    /*
	    Al dar de alta el cuadro, el estado es 1 - Pendiente validar
	    Cuando se trata de un alta de vigencia, sólo se pueden informar las fechas de inicio y final de vigencia.
	    El estado está asociado a la vigencia, de forma que cada vigencia tiene su estado y al dar de alta una vigencia
	    el estado será 1 - Pendiente validar
	    En modificaciones:
	    "  Si estado = 1 - Pendiente Validar, puede modificarse la lista de descripciones por idioma, el tipo y el
	    estado a:
	    o  2 - Validado
	    o  3 - Anulado
	    "  Si  estado =  2 - Validado, sólo puede modificarse el estado a 3 - Anulado
	    o  Se validará que no exista ningún agente que tenga ese cuadro de comisión antes de permitir este cambio.

	    */
	    /*fi validaciones*/
	    /*Nueva vigencia el estado es 1*/
	    IF pmodo='NVIGEN' THEN
	      vcestado:=1;
	    ELSE
	      vcestado:=pcestado;
	    END IF;

	    vnumerr:=pac_md_comisiones.f_set_obj_cuadrocomision(pccomisi, pctipo, vcestado, pfinivig, pffinvig, obcomision, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    vnumerr:=pac_md_comisiones.f_set_traspaso_obj_bd(obcomision, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    IF pmodo='NVIGEN' THEN
	      /*En caso de nueva vigencia duplicamos las tablas comisionprod, comisionacti, comisiongar*/
	      vnumerr:=pac_md_comisiones.f_dup_det_comision(pccomisi, pfinivig, mensajes);

	      IF vnumerr<>0 THEN
	        RAISE e_object_error;
	      END IF;
	    END IF;

	    COMMIT;

	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_set_obj_cuadrocomision;

	/*************************************************************************

	   param in pccomisi   : codigo de comision
	   param in pctipo     : codigo de tipo
	   param in pcestado   : codigo de estado
	   param in pfinivig   : fecha inicio vigencia
	   param in pffinvig   : fecha fin vigencia
	   param in pmodo      : codigo de modo
	   param out mensajes  : mesajes de error

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_set_cuadrocomision(
			pccomisi	IN	NUMBER,
			pctipo	IN	NUMBER,
			pcestado	IN	NUMBER,
			pfinivig	IN	DATE,
			pffinvig	IN	DATE,
			pdescripciones	IN	T_IAX_INFO,
			pmodo	IN	VARCHAR2,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_set_cuadrocomision';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  trobat      BOOLEAN:=FALSE;
	  vcestado    NUMBER;
	BEGIN
	    IF pccomisi IS NULL  OR
	       pdescripciones IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*validaciones*/
	    /*
	    Al dar de alta el cuadro, el estado es 1 - Pendiente validar
	    Cuando se trata de un alta de vigencia, sólo se pueden informar las fechas de inicio y final de vigencia.
	    El estado está asociado a la vigencia, de forma que cada vigencia tiene su estado y al dar de alta una vigencia
	    el estado será 1 - Pendiente validar
	    En modificaciones:
	    "  Si estado = 1 - Pendiente Validar, puede modificarse la lista de descripciones por idioma, el tipo y el
	    estado a:
	    o  2 - Validado
	    o  3 - Anulado
	    "  Si  estado =  2 - Validado, sólo puede modificarse el estado a 3 - Anulado
	    o  Se validará que no exista ningún agente que tenga ese cuadro de comisión antes de permitir este cambio.

	    */
	    /*fi validaciones*/
	    /*Nueva vigencia el estado es 1*/
	    IF pmodo='NVIGEN' THEN
	      vcestado:=1;
	    ELSE
	      vcestado:=pcestado;
	    END IF;

	    obcomision:=ob_iax_cuadrocomision();
	-- Ini TCS_2 - ACL - 22/01/2019
		vnumerr:= pac_md_comisiones.f_valida_cuadro (pccomisi, mensajes);

	IF vnumerr != 0 THEN
		 pac_iobj_mensajes.crea_nuevo_mensaje_var(mensajes, 2,
															89906212,
															pac_iobj_mensajes.crea_variables_mensaje(vnumerr,
																									  1));
		  RAISE e_object_error;
    ELSE
	-- Ini TCS_2 - ACL - 22/01/2019
	    vnumerr:=pac_md_comisiones.f_set_obj_cuadrocomision(pccomisi, pctipo, vcestado, pfinivig, pffinvig, obcomision, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    obcomision.descripciones:=t_iax_desccuadrocomision();

	    FOR i IN pdescripciones.first .. pdescripciones.last LOOP
	        obcomision.descripciones.extend;

	        obcomision.descripciones(obcomision.descripciones.last):=ob_iax_desccuadrocomision ();

	        vpasexec:=5;

	        vnumerr:=pac_md_comisiones.f_set_obj_desccuadro (to_number(pdescripciones(i).nombre_columna), pccomisi, pdescripciones(i).valor_columna, obcomision.descripciones(obcomision.descripciones.last), mensajes);
	    END LOOP;

	    vnumerr:=pac_md_comisiones.f_set_traspaso_obj_bd(obcomision, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    IF pmodo='NVIGEN' THEN
	      /*En caso de nueva vigencia duplicamos las tablas comisionprod, comisionacti, comisiongar*/
	      vnumerr:=pac_md_comisiones.f_dup_det_comision(pccomisi, pfinivig, mensajes);

	      IF vnumerr<>0 THEN
	        RAISE e_object_error;
	      END IF;
	    END IF;
	END IF;   -- Ini TCS_2 - ACL - 22/01/2019
	    COMMIT;

	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_set_cuadrocomision;

	/*************************************************************************
	   Devuel el cuadro de comision cargado en memoria
	   param in pccomisi   : codigo de comision
	   param in pcuadrocomision : cuadro de comision
	   param out mensajes      : mesajes de error

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_get_obj_cuadrocomision(
			ccomisi	IN	NUMBER,
			pcuadrocomision	OUT	OB_IAX_CUADROCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_get_obj_cuadrocomision';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  pcuadros    T_IAX_CUADROCOMISION;
	BEGIN
	    IF obcomision IS NOT NULL THEN
	      pcuadrocomision:=obcomision;
	    ELSE
	      vnumerr:=f_get_cuadrocomision(ccomisi, NULL, NULL, pcuadrocomision, mensajes);

	      IF pcuadrocomision IS NOT NULL THEN
	        obcomision:=pcuadrocomision;
	      END IF;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_obj_cuadrocomision;

	/*************************************************************************
	   Traspasa a la BD el objeto comision
	   param out mensajes      : mesajes de error

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_set_traspaso_obj_bd(
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_set_traspaso_obj_bd';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  trobat      BOOLEAN:=FALSE;
	BEGIN
	    vnumerr:=pac_md_comisiones.f_set_traspaso_obj_bd(obcomision, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    obcomision:=NULL;

	    COMMIT;

	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             ROLLBACK;

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             ROLLBACK;

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             ROLLBACK;

	             RETURN 1;
	END f_set_traspaso_obj_bd;

	/*************************************************************************
	   Duplica un cuadro de comisiones
	   param in pccomisi_ori   : codigo de comision original
	   param in pccomisi_nuevo : codigo de comision nuevo
	   param in ptcomisi_nuevo : texto cuadro comision
	   param out mensajes      : mesajes de error

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_duplicar_cuadro(
			pccomisi_ori	IN	NUMBER,
			pccomisi_nuevo	IN	NUMBER,
			ptcomisi_nuevo	IN	VARCHAR2,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_duplicar_cuadro';
	  vparam      VARCHAR2(500):='parámetros - pccomisi_ori:'
	                        || pccomisi_ori
	                        || ' pccomisi_nuevo:'
	                        || pccomisi_nuevo
	                        || ' ptcomisi_nuevo:'
	                        || ptcomisi_nuevo;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    IF pccomisi_ori IS NULL  OR
	       pccomisi_nuevo IS NULL  OR
	       ptcomisi_nuevo IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*      IF pccomisi_nuevo > 99 THEN*/
	    /*        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001891);*/
	    /*         RAISE e_param_error;*/
	    /*     END IF;*/
	    vnumerr:=pac_md_comisiones.f_duplicar_cuadro(pccomisi_ori, pccomisi_nuevo, ptcomisi_nuevo, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             ROLLBACK;

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             ROLLBACK;

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             ROLLBACK;

	             RETURN 1;
	END f_duplicar_cuadro;

	/*************************************************************************
	   Devuel un cuadro de comision
	   param in pccomisi   : codigo de comision
	   param in pcuadrocomision : cuadro de comision
	   param out mensajes      : mesajes de error

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_get_cuadrocomision(
			pccomisi	IN	NUMBER,
			pfinivig	IN	DATE DEFAULT NULL,
			pffinvig	IN	DATE DEFAULT NULL,
			pcuadrocomision	OUT	OB_IAX_CUADROCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_get_cuadrocomision';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  trobat      BOOLEAN:=FALSE;
	  pcuadros    T_IAX_CUADROCOMISION;
	BEGIN
	    IF pccomisi IS NOT NULL THEN
	      vnumerr:=f_get_cuadroscomision(pccomisi, NULL, NULL, NULL, pfinivig, pffinvig, pcuadros, mensajes);

	      IF vnumerr<>0 THEN
	        RAISE e_object_error;
	      END IF;

	      IF pcuadros IS NULL  OR
	         pcuadros.count=0 THEN
	        vnumerr:=pac_md_comisiones.f_get_cuadrocomision(pcuadros, pccomisi, mensajes);

	        IF vnumerr<>0 THEN
	          RAISE e_object_error;
	        END IF;
	      END IF;
	    ELSE
	      vpasexec:=2;

	      vnumerr:=pac_md_comisiones.f_get_cuadrocomision(pcuadros, pccomisi, mensajes);

	      IF vnumerr<>0 THEN
	        RAISE e_object_error;
	      END IF;
	    END IF;

	    vpasexec:=3;

	    IF obcomision IS NULL THEN
	      t_comision:=NULL;
	    END IF;

	    vpasexec:=4;

	    IF pcuadros IS NOT NULL AND
	       pcuadros.count>0 THEN
	      FOR n IN pcuadros.first .. pcuadros.last LOOP
	          IF pcuadros(n).ffinvig IS NULL THEN
	            obcomision:=pcuadros(n);

	            pcuadrocomision:=pcuadros(n);

	            RETURN 0;
	          END IF;
	      END LOOP;

	      pcuadrocomision:=pcuadros(1);

	      obcomision:=pcuadros(1);
	    END IF;

	    vpasexec:=5;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_cuadrocomision;

	/*************************************************************************
	   Actualiza el ccomisi de un cuadro de comision
	   param in pccomisi_ori   : codigo de comision original
	   param in pccomisi_nuevo : nuevo codigo de comision
	   param out mensajes      : mesajes de error

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_act_ccomisi(
			pccomisi	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_act_ccomisi';
	  vparam      VARCHAR2(500):='parámetros - pccomisi:'
	                        || pccomisi;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  pcuadros    T_IAX_CUADROCOMISION;
	BEGIN
	    IF pccomisi IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*IF pccomisi>99 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001891);

	      RAISE e_param_error;
	    END IF;*/

	    vnumerr:=f_get_cuadroscomision(pccomisi, NULL, NULL, NULL, NULL, NULL, pcuadros, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    IF pcuadros IS NOT NULL AND
	       pcuadros.count>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901365);

	      RAISE e_object_error;
	    END IF;

	    /*  IF obcomision IS NOT NULL
	      THEN
	         obcomision.ccomisi := pccomisi;

	         IF     obcomision.descripciones IS NOT NULL
	            AND obcomision.descripciones.COUNT > 0
	         THEN
	            FOR i IN
	               obcomision.descripciones.FIRST .. obcomision.descripciones.LAST
	            LOOP
	               obcomision.descripciones (i).ccomisi := pccomisi;
	            END LOOP;
	         END IF;
	      END IF;
	    */
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_act_ccomisi;
	FUNCTION f_get_detalle_comision(
			pccomisi	IN	NUMBER,
			pcagrprod	IN	NUMBER,
			pcramo	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			ptodos	IN	NUMBER,
			pfinivig	IN	DATE DEFAULT NULL,
			pffinvig	IN	DATE DEFAULT NULL,
			pt_comision	OUT	T_IAX_DETCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_get_detalle_comision';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    vnumerr:=pac_md_comisiones.f_get_detalle_comision(pccomisi, pcagrprod, pcramo, psproduc, pcactivi, pcgarant, ptodos, NULL, pfinivig, pffinvig, 1, pt_comision, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    t_comision:=pt_comision;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_detalle_comision;
	FUNCTION f_set_detalle_comision(pccomisi	IN	NUMBER,psproduc	IN	NUMBER,pcactivi	IN	NUMBER,pcgarant	IN	NUMBER,pnivel	IN	NUMBER,pcmodcom	IN	NUMBER,pfinivig	IN	DATE,ppcomisi	IN	NUMBER,pninialt	IN	NUMBER,pnfinalt	IN	NUMBER,pccriterio	IN	NUMBER,pndesde	IN	NUMBER,pnhasta	IN	NUMBER,mensajes	OUT	T_IAX_MENSAJES,pdonde	IN	VARCHAR2 DEFAULT NULL /* Bug 24905/131645 - 18/12/2012 - AMC*/

	)
	RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_set_detalle_comision';
	  vparam      VARCHAR2(500):='parámetros - pccomisi	'||pccomisi
                               ||',psproduc	'||psproduc
                               ||',pcactivi	'||pcactivi
                               ||',pcgarant	'||pcgarant
                               ||',pnivel	'||pnivel
                               ||',pcmodcom	'||pcmodcom
                               ||',pfinivig	'||pfinivig
                               ||',ppcomisi	'||ppcomisi
                               ||',pninialt	'||pninialt
                               ||',pnfinalt	'||pnfinalt
                               ||',pccriterio	'||pccriterio
                               ||',pndesde	'||pndesde
                               ||',pnhasta	'||pnhasta
                               ||',pdonde'||pdonde ;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vnivel      NUMBER:=1;
	  trobat      BOOLEAN:=FALSE;
	  vninialt    NUMBER;
	  vnfinalt    NUMBER;
	BEGIN
	    /*p_tab_error(f_sysdate, f_user, 'IAX_SETDETALLE', 0, pccomisi
	                                                        || '#'
	                                                        || psproduc
	                                                        || '#'
	                                                        || pcactivi
	                                                        || '#'
	                                                        || pcgarant
	                                                        || '#'
	                                                        || pnivel
	                                                        || '#'
	                                                        || pcmodcom
	                                                        || '#'
	                                                        || pfinivig
	                                                        || '#'
	                                                        || ppcomisi
	                                                        || '#'
	                                                        || pninialt
	                                                        || '#'
	                                                        || pnfinalt
	                                                        || '##'
	                                                        || pccriterio
	                                                        || '#'
	                                                        || pndesde
	                                                        || '#'
	                                                        || pnhasta, '');*/

	    vpasexec := 2;
      IF pninialt IS NULL THEN
	      IF pcmodcom IN(2, 4) THEN
	        vninialt:=2;
	      ELSE
	        vninialt:=1;
	      END IF;
	    ELSE
	      vninialt:=pninialt;
	    END IF;

	    vpasexec := 3;
      IF pnfinalt IS NULL THEN
	      IF pcmodcom IN(2, 4) THEN
	        vnfinalt:=99;
	      ELSE
	        vnfinalt:=1;
	      END IF;
	    ELSE
	      vnfinalt:=pnfinalt;
	    END IF;

	    vnivel:=pnivel;

	    vpasexec := 4;
      IF pnivel IS NULL THEN
	      IF pcgarant IS NOT NULL THEN
	        vnivel:=3;
	      ELSIF pcactivi IS NOT NULL THEN
	        vnivel:=2;
	      ELSE
	        vnivel:=1;
	      END IF;
	    END IF;

	    /*p_tab_error(f_sysdate, f_user, 'IAX_SETDETALLE', 1,
	                pccomisi || '#' || psproduc || '#' || pcactivi || '#' || pcgarant || '#'
	                || vnivel || '#' || pcmodcom || '#' || pfinivig || '#' || ppcomisi || '#' || vninialt || '#'
	                || vnfinalt,
	                '');*/
	    vpasexec := 5;
      IF vninialt<0  OR
	       vnfinalt<0  OR
	       ppcomisi<0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902884);

	      RAISE e_object_error;
	    END IF;

	    vpasexec := 6;
      IF vninialt>vnfinalt THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902887);

	      RAISE e_object_error;
	    END IF;

	    vpasexec := 7;
      IF t_comision IS NOT NULL AND
	       t_comision.count>0 THEN
	      FOR i IN t_comision.first .. t_comision.last LOOP
	          vpasexec := 8;
            IF t_comision.EXISTS(i) THEN
	          /**/
	            /* Bug 24905/131645 - 18/12/2012 - AMC*/
	            vpasexec := 9;
              IF pdonde IS NULL THEN
	              IF t_comision(i).ccomisi=pccomisi AND
	                 t_comision(i).sproduc=psproduc AND
	                 t_comision(i).nivel=vnivel AND
	                 ((vnivel=2 AND
	                   t_comision(i).cactivi=pcactivi AND
	                   t_comision(i).cgarant IS NULL)  OR
	                  (vnivel=3 AND
	                   t_comision(i).cactivi=pcactivi AND
	                   t_comision(i).cgarant=pcgarant)  OR
	                  (vnivel=1 AND
	                   t_comision(i).cactivi IS NULL AND
	                   t_comision(i).cgarant IS NULL)) AND
	                 t_comision(i).cmodcom=nvl(pcmodcom, t_comision(i).cmodcom) AND
	                 t_comision(i).finivig=nvl(pfinivig, t_comision(i).finivig) THEN
	                /*CMP 02/12/2014*/
	                vpasexec := 10;
                  IF nvl(pac_parametros.f_parproducto_n(psproduc, 'AFECTA_COMISESPPROD'), 0)=1 THEN
	                  IF (vninialt BETWEEN t_comision(i).ninialt AND t_comision(i).nfinalt AND
	                      vnfinalt BETWEEN t_comision(i).ninialt AND t_comision(i).nfinalt) THEN
	                    IF (pndesde BETWEEN t_comision(i).ndesde AND t_comision(i).nhasta AND
	                        pnhasta BETWEEN t_comision(i).ndesde AND t_comision(i).nhasta) THEN
	                      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902885);
	                      RAISE e_object_error;
	                    END IF;
	                  END IF;
	                ELSE
	                  /*JAMF 24/11/2014  26063*/
                    IF nvl (pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'AGENTES_ALTURAS'), 0)=1 THEN
                      vpasexec := 11;
	                    IF vninialt<t_comision(i).ninialt  OR
	                       vnfinalt>t_comision(i).nfinalt THEN
	                      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902885);

	                      RAISE e_object_error;
	                    END IF;
	                  ELSE
	                    vpasexec := 12;
                      IF vninialt BETWEEN t_comision(i).ninialt AND t_comision(i).nfinalt  OR
	                       vnfinalt BETWEEN t_comision(i).ninialt AND t_comision(i).nfinalt  OR
	                       (vninialt<=t_comision(i).ninialt AND
	                        vnfinalt>=t_comision(i).nfinalt) THEN
	                      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902885);

	                      RAISE e_object_error;
	                    END IF;
	                  END IF;
	                END IF;
	              END IF;
	            END IF;

	          /* Fi Bug 24905/131645 - 18/12/2012 - AMC*/
	            /**/
	            vpasexec := 13;
              IF t_comision(i).ccomisi=pccomisi AND
	               t_comision(i).pcomisi=ppcomisi AND
	               t_comision(i).sproduc=psproduc AND
	               t_comision(i).ninialt=vninialt AND
	               t_comision(i).nivel=vnivel AND
	               ((vnivel=2 AND
	                 t_comision(i).cactivi=pcactivi AND
	                 t_comision(i).cgarant IS NULL)  OR
	                (vnivel=3 AND
	                 t_comision(i).cactivi=pcactivi AND
	                 t_comision(i).cgarant=pcgarant)  OR
	                (vnivel=1 AND
	                 t_comision(i).cactivi IS NULL AND
	                 t_comision(i).cgarant IS NULL)) AND
	               t_comision(i).cmodcom=nvl(pcmodcom, t_comision(i).cmodcom) AND
	               t_comision(i).finivig=nvl(pfinivig, t_comision(i).finivig) THEN
	              vpasexec := 14;
                t_comision(i).pcomisi:=ppcomisi;

	              t_comision(i).nfinalt:=vnfinalt;

	              t_comision(i).modificado:=1;

	              trobat:=TRUE;
	            /* p_tab_error(f_sysdate, f_user, 'IAX_SETDETALLE', 1, 'TROBAT', '');*/
	            END IF;
	          END IF;
	      END LOOP;

	      vpasexec := 15;
        IF trobat=FALSE THEN
	        t_comision.extend;

	        t_comision(t_comision.last):=ob_iax_detcomision();

	        vpasexec := 16;
          vnumerr:=pac_md_comisiones.f_set_detalle_comision(pccomisi, psproduc, pcactivi, pcgarant, vnivel, pcmodcom, pfinivig, ppcomisi, vninialt, vnfinalt, pccriterio, pndesde, pnhasta, t_comision(t_comision.last), mensajes);

	        vpasexec := 17;
          t_comision(t_comision.last).modificado:=1;

	        --p_tab_error(f_sysdate, f_user, 'IAX_SETDETALLE', 2, 'EXTENDED', 'pccriterio'|| pccriterio);

	        IF vnumerr<>0 THEN
	          RAISE e_object_error;
	        END IF;
	      END IF;
	    ELSE
	      vpasexec := 18;
        t_comision:=t_iax_detcomision();

	      t_comision.extend;

	      t_comision(t_comision.last):=ob_iax_detcomision();

	      vpasexec := 19;
        vnumerr:=pac_md_comisiones.f_set_detalle_comision(pccomisi, psproduc, pcactivi, pcgarant, vnivel, pcmodcom, pfinivig, ppcomisi, vninialt, vnfinalt, pccriterio, pndesde, pnhasta, t_comision(t_comision.last), mensajes);

	      t_comision(t_comision.last).modificado:=1;

	      --p_tab_error(f_sysdate, f_user, 'IAX_SETDETALLE', 1, 'NEW AND EXTENDED', 'pccriterio'|| pccriterio);
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_set_detalle_comision;
	FUNCTION f_get_detcom_alt(
			pccomisi	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pnivel	IN	NUMBER,
			pcmodcom	IN	NUMBER,
			pfinivig	IN	DATE,
			pt_comision	OUT	T_IAX_DETCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_get_detcom_alt';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  /**/
	  vnivel      NUMBER:=1;
	  trobat      BOOLEAN:=FALSE;
	BEGIN
	    pt_comision:=t_iax_detcomision();

	    vnivel:=pnivel;

	    IF pnivel IS NULL THEN
	      IF pcgarant IS NOT NULL THEN
	        vnivel:=3;
	      ELSIF pcactivi IS NOT NULL THEN
	        vnivel:=2;
	      ELSE
	        vnivel:=1;
	      END IF;
	    END IF;

	    /*p_tab_error(f_sysdate, f_user, 'IAX_f_get_detcom_alt', 1, 'ENTRO', '');*/
	    /*IF t_comision IS NOT NULL
	       AND t_comision.COUNT > 0 THEN
	       p_tab_error(f_sysdate, f_user, 'IAX_f_get_detcom_alt', 1, 'DINS IF', '');

	       FOR i IN t_comision.FIRST .. t_comision.LAST LOOP
	          IF t_comision.EXISTS(i) THEN
	             IF t_comision(i).ccomisi = pccomisi
	                AND t_comision(i).sproduc = psproduc
	                AND t_comision(i).nivel = vnivel
	                AND((vnivel = 2
	                     AND t_comision(i).cactivi = pcactivi
	                     AND t_comision(i).cgarant IS NULL)
	                    OR(vnivel = 3
	                       AND t_comision(i).cactivi = pcactivi
	                       AND t_comision(i).cgarant = pcgarant)
	                    OR(vnivel = 1
	                       AND t_comision(i).cactivi IS NULL
	                       AND t_comision(i).cgarant IS NULL))
	                AND t_comision(i).cmodcom = NVL(pcmodcom, t_comision(i).cmodcom)
	                AND t_comision(i).finivig = NVL(pfinivig, t_comision(i).finivig) THEN
	                pt_comision.EXTEND;
	                pt_comision(pt_comision.LAST) := t_comision(i);
	                trobat := TRUE;
	                p_tab_error(f_sysdate, f_user, 'IAX_f_get_detcom_alt', 1, 'TROBAT', '');
	             END IF;
	          END IF;
	       END LOOP;

	       IF NOT trobat THEN
	          p_tab_error(f_sysdate, f_user, 'IAX_f_get_detcom_alt', 1, 'DINS IF NO TROBAT', '');
	          vnumerr := pac_md_comisiones.f_get_detalle_comision(pccomisi, NULL, NULL,
	                                                              psproduc, pcactivi, pcgarant,
	                                                              0, pcmodcom, pfinivig, NULL,
	                                                              1, pt_comision, mensajes);
	          p_tab_error(f_sysdate, f_user, 'IAX_f_get_detcom_alt', 1, 'NEW AND EXTENDED', '');
	       END IF;
	    ELSE*/
	    /*p_tab_error(f_sysdate, f_user, 'IAX_f_get_detcom_alt', 1, 'DINS ELSE', '');*/
	    pt_comision:=NULL;

	    vnumerr:=pac_md_comisiones.f_get_detalle_comision(pccomisi, NULL, NULL, psproduc, pcactivi, pcgarant, 0, pcmodcom, pfinivig, NULL, 1, pt_comision, mensajes);

	    /*p_tab_error(f_sysdate, f_user, 'IAX_f_get_detcom_alt', 1, 'NEW AND EXTENDED', '');*/
	    /*END IF;*/
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_detcom_alt;
	FUNCTION f_canc_detcom_alt(
			pccomisi	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pnivel	IN	NUMBER,
			pcmodcom	IN	NUMBER,
			pfinivig	IN	DATE,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_canc_detcom_alt';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  /**/
	  vnivel      NUMBER:=1;
	BEGIN
	    vnivel:=pnivel;

	    IF pnivel IS NULL THEN
	      IF pcgarant IS NOT NULL THEN
	        vnivel:=3;
	      ELSIF pcactivi IS NOT NULL THEN
	        vnivel:=2;
	      ELSE
	        vnivel:=1;
	      END IF;
	    END IF;

	    /*p_tab_error(f_sysdate, f_user, 'IAX_f_canc_detcom_alt', 1, 'ENTRO', '');*/
	    IF t_comision IS NOT NULL AND
	       t_comision.count>0 THEN
	      /*p_tab_error(f_sysdate, f_user, 'IAX_f_canc_detcom_alt', 1, 'DINS IF', '');*/
	      FOR i IN t_comision.first .. t_comision.last LOOP
	          IF t_comision.EXISTS(i) THEN
	            IF t_comision(i).ccomisi=pccomisi AND
	               t_comision(i).sproduc=psproduc AND
	               t_comision(i).nivel=vnivel AND
	               ((vnivel=2 AND
	                 t_comision(i).cactivi=pcactivi AND
	                 t_comision(i).cgarant IS NULL)  OR
	                (vnivel=3 AND
	                 t_comision(i).cactivi=pcactivi AND
	                 t_comision(i).cgarant=pcgarant)  OR
	                (vnivel=1 AND
	                 t_comision(i).cactivi IS NULL AND
	                 t_comision(i).cgarant IS NULL)) AND
	               t_comision(i).cmodcom=nvl(pcmodcom, t_comision(i).cmodcom) AND
	               t_comision(i).finivig=nvl(pfinivig, t_comision(i).finivig) THEN
	              t_comision(i).modificado:=0;
	            /*p_tab_error(f_sysdate, f_user, 'IAX_f_canc_detcom_alt', 1, 'TROBAT', '');*/
	            END IF;
	          END IF;
	      END LOOP;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_canc_detcom_alt;
	FUNCTION f_del_detcom_alt(
			pccomisi	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pnivel	IN	NUMBER,
			pcmodcom	IN	NUMBER,
			pfinivig	IN	DATE,
			pninialt	IN	NUMBER,
			pccriterio	IN	NUMBER,
			pnhasta	IN	NUMBER,
			pndesde	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_del_detcom_alt';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  /**/
	  vnivel      NUMBER:=1;
	BEGIN
	    vnivel:=pnivel;

	    IF pnivel IS NULL THEN
	      IF pcgarant IS NOT NULL THEN
	        vnivel:=3;
	      ELSIF pcactivi IS NOT NULL THEN
	        vnivel:=2;
	      ELSE
	        vnivel:=1;
	      END IF;
	    END IF;

	    /*p_tab_error(f_sysdate, f_user, 'IAX_f_del_detcom_alt', 1, 'ENTRO', '');
	    p_tab_error(f_sysdate, f_user, 'IAX_f_del_detcom_alt', 0,
	                pccomisi || '#' || psproduc || '#' || pcactivi || '#' || pcgarant || '#'
	                || vnivel || '#' || pcmodcom || '#' || pfinivig || '#' || pninialt,
	                '');*/
	    IF t_comision IS NOT NULL AND
	       t_comision.count>0 THEN
	      /*p_tab_error(f_sysdate, f_user, 'IAX_f_del_detcom_alt', 1, 'DINS IF', '');*/
	      FOR i IN t_comision.first .. t_comision.last LOOP
	          IF t_comision.EXISTS(i) THEN
	            IF t_comision(i).ccomisi=pccomisi AND
	               t_comision(i).sproduc=psproduc AND
	               t_comision(i).ninialt=pninialt AND
	               t_comision(i).nivel=vnivel AND
	               ((vnivel=2 AND
	                 t_comision(i).cactivi=pcactivi AND
	                 t_comision(i).cgarant IS NULL)  OR
	                (vnivel=3 AND
	                 t_comision(i).cactivi=pcactivi AND
	                 t_comision(i).cgarant=pcgarant)  OR
	                (vnivel=1 AND
	                 t_comision(i).cactivi IS NULL AND
	                 t_comision(i).cgarant IS NULL)) AND
	               t_comision(i).cmodcom=nvl(pcmodcom, t_comision(i).cmodcom) AND
	               t_comision(i).finivig=nvl(pfinivig, t_comision(i).finivig) THEN
	              t_comision(i).modificado:=0;

	              t_comision.DELETE(i);
	            /*p_tab_error(f_sysdate, f_user, 'IAX_f_del_detcom_alt', 1, 'TROBAT', '');*/
	            END IF;
	          END IF;
	      END LOOP;
	    END IF;

	    vnumerr:=pac_md_comisiones.f_del_altura(psproduc, pcactivi, pcgarant, pccomisi, pcmodcom, pfinivig, pninialt, vnivel, pccriterio, pnhasta, pndesde, mensajes);

	    IF vnumerr!=0 THEN
	      ROLLBACK;

	      RAISE e_object_error;
	    END IF;

	    COMMIT;

	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_del_detcom_alt;
	FUNCTION f_set_traspaso_detalle_obj_bd(
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_set_traspaso_detalle_obj_bd';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  trobat      BOOLEAN:=FALSE;
	BEGIN
	    vnumerr:=pac_md_comisiones.f_set_traspaso_detalle_obj_bd(t_comision, mensajes);

	    IF vnumerr=-1 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120466);

	      RETURN -1;
	    ELSIF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    t_comision:=NULL;

	    COMMIT;

	    RETURN vnumerr;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             ROLLBACK;

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             ROLLBACK;

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             ROLLBACK;

	             RETURN 1;
	END f_set_traspaso_detalle_obj_bd;
	FUNCTION f_get_obj_detalle_comision(
			pdetallecomision	OUT	T_IAX_DETCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_get_obj_cuadrocomision';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    pdetallecomision:=t_comision;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_obj_detalle_comision;
	FUNCTION f_get_hist_cuadrocomision(
			pccomisi	IN	NUMBER,
			pdetcomision	OUT	T_IAX_CUADROCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(4000):='PCCOMISI:'
	                         || pccomisi;
	  vobject  VARCHAR2(200):='PAC_MD_COMISIONES.f_get_hist_cuadrocomision';
	  verror   NUMBER;
	BEGIN
	    verror:=pac_md_comisiones.f_get_hist_cuadrocomision(pccomisi, pdetcomision, mensajes);

	    IF verror<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_get_hist_cuadrocomision;
	FUNCTION f_get_detalle_comision_prod(
			pccomisi	IN	NUMBER,
			pcagrprod	IN	NUMBER,
			pcramo	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pfinivig	IN	DATE,
			pt_comision	OUT	T_IAX_DETCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_get_detalle_comision';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    vnumerr:=pac_md_comisiones.f_get_detalle_comision(pccomisi, pcagrprod, pcramo, psproduc, pcactivi, pcgarant, 0, NULL, pfinivig, NULL, 2, pt_comision, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    t_comision:=pt_comision;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_detalle_comision_prod;

	/*************************************************************************
	   Devuelve el detalle de un cuadro de comision al nivel indicado
	   param in psproduc   : codigo de producto
	   param in pcactivi   : codigo de la actividad
	   param in pcgarant   : codigo de la garantia
	   param in pnivel     : codigo de nivel (1-Producto,2-Actividad,3-Garantia)
	   param out pt_comision  :detalles
	   param out mensajes      : mesajes de error

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_get_detalle_nivel(
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pcnivel	IN	NUMBER,
			pccomisi	IN	NUMBER,
			pt_comision	OUT	T_IAX_DETCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_get_detalle_nivel';
	  vparam      VARCHAR2(500):='parámetros - psproduc:'
	                        || psproduc
	                        || ' pcactivi:'
	                        || pcactivi
	                        || ' pcgarant:'
	                        || pcgarant
	                        || ' pcnivel:'
	                        || pcnivel;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vt_comision T_IAX_DETCOMISION;
	BEGIN
	    IF pcnivel IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vt_comision:=t_iax_detcomision();

	    /*    FOR i IN t_comision.FIRST .. t_comision.LAST LOOP
	              vt_comision.EXTEND;
	              vt_comision(vt_comision.LAST) := t_comision(i);
	        end loop;*/
	    /*psproduc := 274;*/
	    /*ICV REVISAR QUITAR ESTE IF*/
	    /*if psproduc is not null or pcactivi is not null or pcgarant is not null then*/
	    IF pcnivel=1 THEN
	      /*IF psproduc IS NULL
	         AND pccomisi IS NULL THEN
	         RAISE e_param_error;
	      END IF;*/
	      IF t_comision IS NOT NULL AND
	         t_comision.count>0 THEN
	        FOR i IN t_comision.first .. t_comision.last LOOP
	            IF ((pccomisi IS NOT NULL AND
	                 t_comision(i).ccomisi=pccomisi)  OR
	                pccomisi IS NULL) AND
	               ((psproduc IS NOT NULL AND
	                 t_comision(i).sproduc=psproduc)  OR
	                psproduc IS NULL) AND
	               t_comision(i).cactivi IS NULL AND
	               t_comision(i).cgarant IS NULL AND
	               t_comision(i).nivel=pcnivel THEN
	              vt_comision.extend;

	              vt_comision(vt_comision.last):=t_comision(i);
	            END IF;
	        END LOOP;
	      END IF;
	    ELSIF pcnivel=2 THEN
	      IF psproduc IS NULL  OR
	         (pcactivi IS NULL AND
	          pccomisi IS NULL) THEN
	        RAISE e_param_error;
	      END IF;

	      IF t_comision IS NOT NULL AND
	         t_comision.count>0 THEN
	        FOR i IN t_comision.first .. t_comision.last LOOP
	            IF ((pccomisi IS NOT NULL AND
	                 t_comision(i).ccomisi=pccomisi)  OR
	                pccomisi IS NULL) AND
	               ((psproduc IS NOT NULL AND
	                 t_comision(i).sproduc=psproduc)  OR
	                psproduc IS NULL) AND
	               ((pcactivi IS NOT NULL AND
	                 t_comision(i).cactivi=pcactivi)  OR
	                pcactivi IS NULL) AND
	               t_comision(i).cgarant IS NULL AND
	               t_comision(i).nivel=pcnivel THEN
	              vt_comision.extend;

	              vt_comision(vt_comision.last):=t_comision(i);
	            END IF;
	        END LOOP;
	      END IF;
	    ELSIF pcnivel=3 THEN
	      IF psproduc IS NULL  OR
	         pcactivi IS NULL  OR
	         (pcgarant IS NULL AND
	          pccomisi IS NULL) THEN
	        RETURN 0;

	        RAISE e_param_error;
	      END IF;

	      IF t_comision IS NOT NULL AND
	         t_comision.count>0 THEN
	        FOR i IN t_comision.first .. t_comision.last LOOP
	            IF ((pccomisi IS NOT NULL AND
	                 t_comision(i).ccomisi=pccomisi)  OR
	                pccomisi IS NULL) AND
	               ((psproduc IS NOT NULL AND
	                 t_comision(i).sproduc=psproduc)  OR
	                psproduc IS NULL) AND
	               ((pcactivi IS NOT NULL AND
	                 t_comision(i).cactivi=pcactivi)  OR
	                pcactivi IS NULL) AND
	               ((pcgarant IS NOT NULL AND
	                 t_comision(i).cgarant=pcgarant)  OR
	                pcgarant IS NULL) AND
	               t_comision(i).nivel=pcnivel THEN
	              vt_comision.extend;

	              vt_comision(vt_comision.last):=t_comision(i);
	            END IF;
	        END LOOP;
	      END IF;
	    END IF;

	    /*end if;*/
	    pt_comision:=vt_comision;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_get_detalle_nivel;

	/*************************************************************************
	   Devuelve los cuadros de comision con su % si lo tiene asignado
	   param in psproduc   : codigo de producto
	   param in pcactivi   : codigo de la actividad
	   param in pcgarant   : codigo de la garantia
	   param in pnivel     : codigo de nivel (1-Producto,2-Actividad,3-Garantia)

	   param out pt_comision   : detalle cuadros comision
	   param out mensajes   : mensajes de error

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_get_porproducto(
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pcnivel	IN	NUMBER,
			pcfinivig	IN	DATE,
			pt_comision	OUT	T_IAX_DETCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(4000):='psproduc:'
	                         || psproduc
	                         || ' pcactivi:'
	                         || pcactivi
	                         || ' pcgarant:'
	                         || pcgarant
	                         || ' pcnivel:'
	                         || pcnivel;
	  vobject  VARCHAR2(200):='PAC_IAX_COMISIONES.f_get_porproducto';
	  verror   NUMBER;
	BEGIN
	    IF pcnivel IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    IF pcnivel=1 AND
	       psproduc IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    IF pcnivel=2 AND
	       psproduc IS NULL AND
	       pcactivi IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    IF pcnivel=3 AND
	       psproduc IS NULL AND
	       pcactivi IS NULL AND
	       pcgarant IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    verror:=pac_md_comisiones.f_get_porproducto(psproduc, pcactivi, pcgarant, pcnivel, pcfinivig, pt_comision, mensajes);

	    /* Cargamos en el objeto los porcentajes de comision que se haigan modificado en el t_comision*/
	    FOR n IN pt_comision.first .. pt_comision.last LOOP
	        FOR i IN t_comision.first .. t_comision.last LOOP
	            IF pt_comision(n).ccomisi=t_comision(i).ccomisi AND
	               pt_comision(n).sproduc=t_comision(i).sproduc AND
	               nvl(pt_comision(n).cactivi, -1)=nvl(t_comision(i).cactivi, -1) AND
	               nvl(pt_comision(n).cgarant, -1)=nvl(t_comision(i).cgarant, -1) AND
	               pt_comision(n).cmodcom=t_comision(i).cmodcom AND
	               nvl(pt_comision(n).ninialt, -1)=nvl(t_comision(i).ninialt, -1) THEN
	              pt_comision(n).pcomisi:=t_comision(i).pcomisi;

	              pt_comision(n).ninialt:=t_comision(i).ninialt;

	              pt_comision(n).nfinalt:=t_comision(i).nfinalt;
	            END IF;
	        END LOOP;
	    END LOOP;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_get_porproducto;

	/*************************************************************************
	   Recupera las fechas de vigencias de los cuadroas
	   param in pccomisi   : codigo de comision
	   param in pctipo     : codigo de tipo de consulta
	   param out mensajes  : mensajes de error
	   return              : codigo de error
	*************************************************************************/
	FUNCTION f_get_lsfechasvigencia(
			psproduc	IN	NUMBER,
			pctipo	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  cur          SYS_REFCURSOR;
	  v_pasexec    NUMBER(8):=1;
	  v_param      VARCHAR2(200):=' psproduc = '
	                         || psproduc
	                         || ' pctipo:'
	                         || pctipo;
	  v_object     VARCHAR2(200):='PAC_IAX_COMISIONES.f_get_lsfechasvigencia';
	  vobdetpoliza OB_IAX_DETPOLIZA;
	BEGIN
	    cur:=pac_md_comisiones.f_get_lsfechasvigencia(psproduc, pctipo, mensajes);

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);

	             RETURN cur; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_get_lsfechasvigencia;

	/*************************************************************************
	   Duplica un cuadro de comisiones de un producto
	   param in pccomisi_ori   : codigo de comision original
	   param in pccomisi_nuevo : codigo de comision nuevo
	   param in ptcomisi_nuevo : texto cuadro comision
	   param in pidioma        : codigo de idioma

	   return : codigo de error
	*************************************************************************/
	FUNCTION f_duplicar_cuadro_prod(
			pcsproduc	IN	NUMBER,
			pfinivig	IN	DATE,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_duplicar_cuadro_prod';
	  vparam      VARCHAR2(500):='parámetros - pcsproduc:'
	                        || pcsproduc
	                        || ' pfinivig:'
	                        || pfinivig;
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  vcount      NUMBER;
	BEGIN
	    IF pcsproduc IS NULL  OR
	       pfinivig IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT count(1)
	      INTO vcount
	      FROM comisionprod p,productos prod
	     WHERE p.cramo=prod.cramo AND
	           p.cmodali=prod.cmodali AND
	           p.ctipseg=prod.ctipseg AND
	           p.ccolect=prod.ccolect AND
	           prod.sproduc=pcsproduc AND
	           p.finivig=pfinivig;

	    IF vcount>0 THEN
	      vnumerr:=101490;
	    END IF;

	    vnumerr:=pac_md_comisiones.f_duplicar_cuadro_prod(pcsproduc, pfinivig, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             ROLLBACK;

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             ROLLBACK;

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             ROLLBACK;

	             RETURN 1;
	END f_duplicar_cuadro_prod;
	FUNCTION f_get_alturas(
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pccomisi	IN	NUMBER,
			pcmodcom	IN	NUMBER,
			pfinivig	IN	DATE,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  vparam      VARCHAR2(500):='paràmetres - psproduc: '
	                        || psproduc
	                        || ' - pcactivi:'
	                        || pcactivi;
	  vobjectname VARCHAR2(200):='PAC_IAX_COMISIONES.f_get_alturas';
	  vnumerr     NUMBER;
	BEGIN
	    RETURN pac_md_comisiones.f_get_alturas(psproduc, pcactivi, pcgarant, pccomisi, pcmodcom, pfinivig, mensajes);
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, 1, vparam);

	             RETURN NULL; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, 1, vparam, vnumerr);

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, 1, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_get_alturas;

	/*************************************************************************
	  Inserta el desglose del % de comision
	  param in pcactivi     Código de la actividad
	  param in pcgarant     Código de la garantia
	  param in pccomisi     Código comisión
	  param in pcmodcom     Código de la modalidad de comisión
	  param in pfinivig     Fecha inicio vigencia comisión
	  param in pninialt     Inicio de la altura
	  param in psproduc     Codi producte
	  param in pnfinalt     Fin de la altura

	  return : codigo de error
	  Bug 24905/131645 - 11/12/2012 - AMC
	*************************************************************************/
	FUNCTION f_set_comisiondesglose(
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pccomisi	IN	NUMBER,
			pcmodcom	IN	NUMBER,
			pfinivig	IN	DATE,
			pninialt	IN	NUMBER,
			psproduc	IN	NUMBER,
			pnfinalt	IN	NUMBER,
			pnivel	IN	NUMBER,
			pccriterio	IN	NUMBER,
			pndesde	IN	NUMBER,
			pnhasta	IN	NUMBER,
			desglose	IN	T_IAX_INFO,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000):='parametres -  pcactivi:'
	                         || pcactivi
	                         || ' pcgarant:'
	                         || pcgarant
	                         || ' pccomisi:'
	                         || pccomisi
	                         || ' pcmodcom:'
	                         || pcmodcom
	                         || ' pfinivig:'
	                         || pfinivig
	                         || ' pninialt:'
	                         || pninialt
	                         || ' psproduc:'
	                         || psproduc
	                         || ' pnfinalt:'
	                         || pnfinalt;
	  vobjectname VARCHAR2(200):='PAC_IAX_COMISIONES.f_set_comisiondesglose';
	  vpcomisi    NUMBER:=0;
	  vnls_bd     VARCHAR2(100):='NLS_NUMERIC_CHARACTERS = '
	                         || chr(39)
	                         || pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'SISTEMA_NUMERICO_BD')
	                         || chr(39);
	BEGIN
	    vpasexec:=1;

	    IF desglose IS NOT NULL THEN
	      IF desglose.count>0 THEN
	        FOR i IN desglose.first .. desglose.last LOOP
	            IF desglose(i).nombre_columna IS NOT NULL THEN
	              vpasexec:=2;

	              vnumerr:=pac_md_comisiones.f_set_comisiondesglose (pcactivi, pcgarant, pccomisi, pcmodcom, pfinivig, pninialt, desglose(i).nombre_columna, to_number(nvl(desglose(i).valor_columna, '0'), '9999999999999D99999999999', vnls_bd), psproduc, pnfinalt, mensajes);

	              vpasexec:=3;

	              vpcomisi:=vpcomisi
	                        +to_number(nvl(desglose(i).valor_columna, '0'), '9999999999999D99999999999', vnls_bd);

	              vpasexec:=4;

	              IF vnumerr<>0 THEN
	                RAISE e_object_error;
	              END IF;
	            END IF;
	        END LOOP;
	      END IF;
	    END IF;

	    vpasexec:=5;

	    vnumerr:=f_set_detalle_comision(pccomisi, psproduc, pcactivi, pcgarant, pnivel, pcmodcom, pfinivig, vpcomisi, pninialt, pnfinalt, pccriterio, pndesde, pnhasta, mensajes, 'DESGLOSES');

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             ROLLBACK;

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             ROLLBACK;

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             ROLLBACK;

	             RETURN 1;
	END f_set_comisiondesglose;

	/*************************************************************************
	   Recupera el desglose del % de comision
	   param in pcactivi     Código de la actividad
	   param in pcgarant     Código de la garantia
	   param in pccomisi     Código comisión
	   param in pcmodcom     Código de la modalidad de comisión
	   param in pfinivig     Fecha inicio vigencia comisión
	   param in pninialt     Inicio de la altura

	   return : desglose
	   Bug 24905/131645 - 13/12/2012 - AMC
	*************************************************************************/
	FUNCTION f_get_comisiondesglose(
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pccomisi	IN	NUMBER,
			pcmodcom	IN	NUMBER,
			pfinivig	IN	DATE,
			pninialt	IN	NUMBER,
			psproduc	IN	NUMBER,
			pnfinalt	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  vpasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000):='parametres -  pcactivi:'
	                         || pcactivi
	                         || ' pcgarant:'
	                         || pcgarant
	                         || ' pccomisi:'
	                         || pccomisi
	                         || ' pcmodcom:'
	                         || pcmodcom
	                         || ' pfinivig:'
	                         || pfinivig
	                         || ' pninialt:'
	                         || pninialt
	                         || ' psproduc:'
	                         || psproduc
	                         || ' pnfinalt:'
	                         || pnfinalt;
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_get_comisiondesglose';
	  cur         SYS_REFCURSOR;
	BEGIN
	    vpasexec:=1;

	    IF psproduc IS NULL  OR
	       pccomisi IS NULL  OR
	       pcmodcom IS NULL  OR
	       pninialt IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    cur:=pac_md_comisiones.f_get_comisiondesglose(pcactivi, pcgarant, pccomisi, pcmodcom, pfinivig, pninialt, psproduc, pnfinalt, mensajes);

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN NULL;
	END f_get_comisiondesglose;

	/*************************************************************************
	  Borra el desglose del % de comision
	  param in pcactivi     Código de la actividad
	  param in pcgarant     Código de la garantia
	  param in pccomisi     Código comisión
	  param in pcmodcom     Código de la modalidad de comisión
	  param in pfinivig     Fecha inicio vigencia comisión
	  param in pninialt     Inicio de la altura
	  param in psproduc     Codi producte
	  param in pnfinalt     Fin de la altura

	  return : codigo de error
	  Bug 24905/131645 - 14/12/2012 - AMC
	*************************************************************************/
	FUNCTION f_del_comisiondesglose(
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pccomisi	IN	NUMBER,
			pcmodcom	IN	NUMBER,
			pfinivig	IN	DATE,
			pninialt	IN	NUMBER,
			psproduc	IN	NUMBER,
			pnfinalt	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000):='parametres -  pcactivi:'
	                         || pcactivi
	                         || ' pcgarant:'
	                         || pcgarant
	                         || ' pccomisi:'
	                         || pccomisi
	                         || ' pcmodcom:'
	                         || pcmodcom
	                         || ' pfinivig:'
	                         || pfinivig
	                         || ' pninialt:'
	                         || pninialt
	                         || ' psproduc:'
	                         || psproduc
	                         || ' pnfinalt:'
	                         || pnfinalt;
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_del_comisiondesglose';
	BEGIN
	    vpasexec:=1;

	    vnumerr:=pac_md_comisiones.f_del_comisiondesglose(pcactivi, pcgarant, pccomisi, pcmodcom, pfinivig, pninialt, psproduc, pnfinalt, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_del_comisiondesglose;

	/*************************************************************************
	    Recupera fecha vigencia
	    param in pccomisi     Código comisión

	    return : fecha de vigencia

	 *************************************************************************/
	FUNCTION f_get_fechavigencia(
			pccomisi	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN DATE
	IS
	  vpasexec    NUMBER;
	  vnumerr     NUMBER;
	  vfecha      DATE;
	  vparam      VARCHAR2(1000):='parametres -   pccomisi:'
	                         || pccomisi;
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_get_fechavigencia';
	BEGIN
	    vpasexec:=1;

	    IF pccomisi IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vfecha:=pac_md_comisiones.f_get_fechavigencia(pccomisi, mensajes);

	    RETURN vfecha;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_get_fechavigencia;

	/*************************************************************************
	Inserta el parà metre per porcentaje de retrocesiòn
	param in pnempres     : Código empresa
	param in pnmesi      : Mes inicial
	param in pnmesf     : Mes final
	param in pnanulac  : Porcentaje de retrocesiòn
	*************************************************************************/
	FUNCTION f_ins_confclawback(
			pnempres	IN	NUMBER,
			pnmesi	IN	NUMBER,
			pnmesf	IN	NUMBER,
			pnanulac	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vnumerr     NUMBER(8):=0;
	  vpasexec    NUMBER(8):=1;
	  vparam      VARCHAR2(500):='parametros  - pnempres: '
	                        || pnempres
	                        || ' - pnmesi: '
	                        || pnmesi
	                        || ' - pnmesf: '
	                        || pnmesf
	                        || ' - pnanulac: '
	                        || pnanulac;
	  vobjectname VARCHAR2(200):='PAC_IAX_COMISIONES.f_ins_confclawback';
	  verror      NUMBER;
	BEGIN
	    verror:=pac_md_comisiones.f_ins_confclawback(pnempres, pnmesi, pnmesf, pnanulac, mensajes);

	    IF verror<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_ins_confclawback;

	/*************************************************************************
	Actualitzar  el parà metre per porcentaje de retrocesiòn
	param in pnempres     : Código empresa
	param in pnmesi      : Mes inicial
	param in pnmesf     : Mes final
	param in pnanulac  : Porcentaje de retrocesiòn
	*************************************************************************/
	FUNCTION f_upd_confclawback(
			pnempres	IN	NUMBER,
			pnmesi_old	IN	NUMBER,
			pnmesi_new	IN	NUMBER,
			pnmesf_old	IN	NUMBER,
			pnmesf_new	IN	NUMBER,
			pnanulac_old	IN	NUMBER,
			pnanulac_new	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vnumerr     NUMBER(8):=0;
	  vpasexec    NUMBER(8):=1;
	  vparam      VARCHAR2(500):='parametros  - pnempres: '
	                        || pnempres
	                        || ' - pnmesi: '
	                        || pnmesi_old
	                        || ' - pnmesf: '
	                        || pnmesf_old
	                        || ' - pnanulac: '
	                        || pnanulac_old;
	  vobjectname VARCHAR2(200):='PAC_IAX_COMISIONES.f_upd_confclawback';
	  verror      NUMBER;
	BEGIN
	    verror:=pac_md_comisiones.f_upd_confclawback(pnempres, pnmesi_old, pnmesi_new, pnmesf_old, pnmesf_new, pnanulac_old, pnanulac_new, mensajes);

	    IF verror<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_upd_confclawback;

	/*************************************************************************
	  Esborrar  el parà metre per porcentaje de retrocesiòn
	  param in pnempres     : Código empresa
	  param in pnmesi      : Mes inicial
	  param in pnmesf     : Mes final
	  param in pnanulac  : Porcentaje de retrocesiòn
	  return              : 0.- OK, 1.- KO
	  *************************************************************************/
	FUNCTION f_del_confclawback(
			pnempres	IN	NUMBER,
			pnmesi	IN	NUMBER,
			pnmesf	IN	NUMBER,
			pnanulac	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vnumerr     NUMBER(8):=0;
	  vpasexec    NUMBER(8):=1;
	  vparam      VARCHAR2(500):='parametros  - pnempres: '
	                        || pnempres
	                        || ' - pnmesi: '
	                        || pnmesi
	                        || ' - pnmesf: '
	                        || pnmesf
	                        || ' - pnanulac: '
	                        || pnanulac;
	  vobjectname VARCHAR2(200):='PAC_IAX_COMISIONES.f_del_confclawback ';
	  verror      NUMBER;
	BEGIN
	    verror:=pac_md_comisiones.f_del_confclawback(pnempres, pnmesi, pnmesf, pnanulac, mensajes);

	    IF verror<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_del_confclawback;

	/*************************************************************************
	    Recupera datos de porcentajes de retrocesion de comisiones
	    param in pnempres     : Código empresa
	    param in pnmesi      : Mes inicial
	    param in pnmesf     : Mes final
	    param in pnanulac  : Porcentaje de retrocesiòn
	    return              : codigo de error
	 *************************************************************************/
	FUNCTION f_get_confclawback(
			pnempres	IN	NUMBER,
			pnmesi	IN	NUMBER,
			pnmesf	IN	NUMBER,
			pnanulac	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  cur      SYS_REFCURSOR;
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(4000):='parametros  - pnempres: '
	                         || pnempres
	                         || ' - pnmesi: '
	                         || pnmesi
	                         || ' - pnmesf: '
	                         || pnmesf
	                         || ' - pnanulac: '
	                         || pnanulac;
	  vobject  VARCHAR2(200):='PAC_IAX_COMISIONES.f_get_confclawback';
	  verror   NUMBER;
	BEGIN
	    cur:=pac_md_comisiones.f_get_confclawback(pnempres, pnmesi, pnmesf, pnanulac, mensajes);

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             RETURN cur; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_get_confclawback;


	/*************************************************************************
	Recupera  los datos de cuadros de comisiones ya existentes
	param in ccomisi     : Código de comision
	return               : Numero de codigo de comision
	*************************************************************************/
	FUNCTION f_valida_cuadro(
      pccomisi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pccomisi:' || pccomisi;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMISIONES.f_valida_cuadro';
      verror         NUMBER;
   BEGIN

      verror :=
         pac_md_comisiones.f_valida_cuadro(pccomisi, mensajes);
      vpasexec := 2;

      IF verror != 0 THEN
          pac_iobj_mensajes.crea_nuevo_mensaje_var(mensajes, 2,
                                                        89906212,
                                                        pac_iobj_mensajes.crea_variables_mensaje(verror,
                                                                                                  1));
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN verror;
   EXCEPTION
      WHEN e_param_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_valida_cuadro;


   	/*************************************************************************
	Elimina  los datos del cuadro de comision elegido
	param in ccomisi     : Código de comision
	return               : Mensaje de error
	*************************************************************************/
      FUNCTION f_anular_cuadro(pccomisi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccomisi = ' || pccomisi;
      vobject        VARCHAR2(200) := 'PAC_IAX_COMISIONES.F_ANULAR_CUADRO';
   BEGIN
      vpasexec := 1;

      IF pccomisi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_comisiones.f_anular_cuadro(pccomisi, mensajes);

      IF v_result = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      ELSIF v_result = 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1000455);
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 1000455);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9900993, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_anular_cuadro;
END pac_iax_comisiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_COMISIONES" TO "PROGRAMADORESCSI";
