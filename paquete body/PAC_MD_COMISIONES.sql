--------------------------------------------------------
--  DDL for Package Body PAC_MD_COMISIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_COMISIONES" IS

   /******************************************************************************
      NOMBRE:     PAC_MD_COMISIONES
      PROPÓSITO:  Funciones de cuadros de comisiones

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        21/07/2010   AMC               1. Creación del package.
      2.0        14/09/2010   ICV               2. 0015137: MDP Desarrollo de Cuadro Comisiones
      3.0        12/09/2011   JTS               3. 19316: CRT - Adaptar pantalla de comisiones
      4.0        21/05/2015   VCG               4. 033977-204336: MSV: Creación de funciones
      5.0        26/04/2016   VCG               5. 41737-234272:AMA - Eliminar el idioma catalán, que no se visualice en el mant. de comisiones
	  6.0        22/01/2019   ACL         		6. TCS_2 Se crean las funciones f_valida_cuadro y f_anular_cuadro.
   ******************************************************************************/

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
	  vsquery  VARCHAR2(1000);
	  verror   NUMBER;
	  cur      SYS_REFCURSOR;
	  vccomisi NUMBER;
	  vtcomisi VARCHAR2(500);
	  vctipo   NUMBER;
	  vttipo   VARCHAR2(500);
	  vfinivig DATE;
	  vffinvig DATE;
	  vcestado NUMBER;
	BEGIN
	    verror:=pac_comisiones.f_get_cuadroscomision(pccomisi, ptcomisi, pctipo, pcestado, pffechaini, pffechafin, pac_md_common.f_get_cxtidioma, vsquery);

	    IF verror<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);

	      RAISE e_object_error;
	    END IF;

	    cur:=pac_md_listvalores.f_opencursor(vsquery, mensajes);

	    IF pcuadros IS NULL THEN
	      pcuadros:=t_iax_cuadrocomision();
	    END IF;

	    LOOP
	        FETCH cur INTO vccomisi, vtcomisi, vctipo, vfinivig, vffinvig, vcestado;

	        EXIT WHEN cur%NOTFOUND;

	        pcuadros.extend;

	        pcuadros(pcuadros.last):=ob_iax_cuadrocomision();

	        pcuadros(pcuadros.last).ccomisi:=vccomisi;

	        pcuadros(pcuadros.last).tcomisi:=vtcomisi;

	        pcuadros(pcuadros.last).ctipo:=vctipo;

	        pcuadros(pcuadros.last).finivig:=vfinivig;

	        pcuadros(pcuadros.last).ffinvig:=vffinvig;

	        pcuadros(pcuadros.last).cestado:=vcestado;

	        pcuadros(pcuadros.last).ttipo:=ff_desvalorfijo(1015, pac_md_common.f_get_cxtidioma, vctipo);

	        pcuadros(pcuadros.last).testado:=ff_desvalorfijo(1016, pac_md_common.f_get_cxtidioma, vcestado);

	        verror:=pac_md_comisiones.f_get_desccomisiones(pccomisi, pcuadros(pcuadros.last).descripciones, mensajes);
	    END LOOP;

	    CLOSE cur;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1;
	END f_get_cuadroscomision;

	/*************************************************************************
	    Recupera las descripciones de las comisiones
	    param in pccomisi   : codigo de comision
	    param out pcuadros  : objeto con las descripciones
	    param out mensajes  : mesajes de error
	    return              : descripción del valor
	 *************************************************************************/
	FUNCTION f_get_desccomisiones(
			pccomisi	IN	NUMBER,
			pcuadros	OUT	T_IAX_DESCCUADROCOMISION,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(4000):='PCCOMISI:'
	                         || pccomisi;
	  vobject  VARCHAR2(200):='PAC_MD_COMISIONES.f_get_desccomisiones';
	BEGIN
	    IF pcuadros IS NULL THEN
	      pcuadros:=t_iax_desccuadrocomision();
	    END IF;

	    FOR cur IN (SELECT nvl(d.cidioma, i.cidioma) cidioma,d.ccomisi,d.tcomisi,i.tidioma
	                  FROM descomision d,idiomas i
	                 WHERE d.ccomisi(+)=pccomisi AND
	                       d.cidioma(+)=i.cidioma AND
                         i.cvisible = 1
	                 ORDER BY i.cidioma) LOOP
	        pcuadros.extend;

	        pcuadros(pcuadros.last):=ob_iax_desccuadrocomision();

	        pcuadros(pcuadros.last).cidioma:=cur.cidioma;

	        pcuadros(pcuadros.last).tidioma:=cur.tidioma;

	        pcuadros(pcuadros.last).ccomisi:=nvl(cur.ccomisi, pccomisi);

	        pcuadros(pcuadros.last).tcomisi:=cur.tcomisi;
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
	END f_get_desccomisiones;

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
			pdescripciones	IN	OUT OB_IAX_DESCCUADROCOMISION,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_md_comisiones.f_set_obj_desccuadro';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    pdescripciones.cidioma:=pcidioma;

	    pdescripciones.tidioma:=''; --select tidioma;

	    pdescripciones.ccomisi:=pccomisi;

	    pdescripciones.tcomisi:=ptcomisi;

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
			pcomision	IN	OUT OB_IAX_CUADROCOMISION,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_md_comisiones.f_set_obj_cuadrocomision';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    pcomision.cestado:=pcestado;

	    pcomision.testado:=''; --desvalorfijo(testado,xx);

	    pcomision.ccomisi:=pccomisi;

	    pcomision.tcomisi:='';

	    pcomision.finivig:=pfinivig;

	    pcomision.ctipo:=pctipo;

	    pcomision.ttipo:=''; --desvalorfijo(ctipo,xx);

	    pcomision.ffinvig:=pffinvig;

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
	END f_set_obj_cuadrocomision;

	/*************************************************************************
	  Devuel un cuadro de comision
	  param in out pcomision   : cuadro de comision
	  param out mensajes      : mesajes de error

	  return : codigo de error
	*************************************************************************/
	FUNCTION f_set_traspaso_obj_bd(
			pcomision	IN	OUT OB_IAX_CUADROCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_md_comisiones.f_set_traspaso_obj_bd';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	BEGIN
	    vnumerr:=pac_comisiones.f_set_cab_comision(pcomision.ccomisi, pcomision.ctipo, pcomision.cestado, pcomision.finivig, pcomision.ffinvig);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

	    FOR i IN pcomision.descripciones.first .. pcomision.descripciones.last LOOP
	        IF pcomision.descripciones(i).tcomisi IS NOT NULL THEN
	          vnumerr:=pac_comisiones.f_set_desccomision(pcomision.ccomisi, pcomision.descripciones(i).cidioma, pcomision.descripciones(i).tcomisi);

	          IF vnumerr<>0 THEN
	            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	            RAISE e_object_error;
	          END IF;
	        END IF;
	    END LOOP;

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
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_md_comisiones.f_duplicar_cuadro';
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

	    vnumerr:=pac_comisiones.f_duplicar_cuadro(pccomisi_ori, pccomisi_nuevo, ptcomisi_nuevo, pac_md_common.f_get_cxtidioma);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
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
	END f_duplicar_cuadro;

	/*************************************************************************
	  Inicializa un cuadro de comisiones
	  param out pcuadros  : cuadros de comision
	  param out mensajes  : mensajes de error
	  return              : codigo de error
	*************************************************************************/
	FUNCTION f_get_cuadrocomision(
			pcuadros	OUT	T_IAX_CUADROCOMISION,
			pccomisi	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(4000):='';
	  vobject  VARCHAR2(200):='PAC_MD_COMISIONES.f_get_cuadrocomision';
	  verror   NUMBER;
	BEGIN
	    pcuadros:=t_iax_cuadrocomision();

	    pcuadros.extend;

	    pcuadros(pcuadros.last):=ob_iax_cuadrocomision();

	    pcuadros(pcuadros.last).cestado:=1;

	    pcuadros(pcuadros.last).testado:=ff_desvalorfijo(1016, pac_md_common.f_get_cxtidioma, 1);

	    pcuadros(pcuadros.last).ccomisi:=pccomisi;

	    verror:=pac_md_comisiones.f_get_desccomisiones(pcuadros(pcuadros.last).ccomisi, pcuadros(pcuadros.last).descripciones, mensajes);

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             RETURN 1;
	END f_get_cuadrocomision;
	FUNCTION f_get_detalle_comision(
			pccomisi	IN	NUMBER,
			pcagrprod	IN	NUMBER,
			pcramo	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			ptodos	IN	NUMBER,
			pcmodcon	IN	NUMBER,
			pfinivig	IN	DATE DEFAULT NULL,
			pffinvig	IN	DATE DEFAULT NULL,
			porderby	IN	NUMBER,
			pt_comision	IN	OUT T_IAX_DETCOMISION,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname  VARCHAR2(500):='pac_md_comisiones.f_get_detalle_comision';
	  vparam       VARCHAR2(500):='parámetros - ';
	  vpasexec     NUMBER(5):=1;
	  verror       NUMBER(8):=0;
	  vsproduc     NUMBER(6);
	  vttitulo     VARCHAR2(500);
	  vtrotulo     VARCHAR2(500);
	  vcactivi     NUMBER(4);
	  vtactivi     VARCHAR2(500);
	  vcgarant     NUMBER(4);
	  vtgarant     VARCHAR2(500);
	  vnivel       NUMBER(1); /* 1 productos, 2 actividad, 3 garantia*/
	  vfinivig     DATE;
	  vffinvig     DATE;
	  vcmodcom     NUMBER(1); /* Código de modalidad de la comisión*/
	  vtmodcom     VARCHAR2(500);
	  vccomisi     NUMBER;
	  vtcomisi     VARCHAR2(500);
	  vpcomisi     FLOAT; /* Porcentaje de comisión*/
	  vquery       VARCHAR2(32000);
	  vninialt     NUMBER;
	  vnfinalt     NUMBER;
	  cur          SYS_REFCURSOR;
	  vobjcomision OB_IAX_DETCOMISION;
	  vdesglose    NUMBER; /*Bug 24905/131645 - 17/12/2012 - AMC*/
	  ccriterio    NUMBER; /*msv*/
	  ndesde       NUMBER; /*msv*/
	  nhasta       NUMBER; /*msv*/
	  tcriterio    VARCHAR(100); /*msv*/
	BEGIN
	    vpasexec:=1;

	    verror:=pac_comisiones.f_get_detalle_comision(pccomisi, pcagrprod, pcramo, psproduc, pcactivi, pcgarant, ptodos, pfinivig, pffinvig, porderby, pac_md_common.f_get_cxtidioma, pcmodcon, vquery);

	    vpasexec:=2;

	    cur:=pac_md_listvalores.f_opencursor(vquery, mensajes);

	    IF pt_comision IS NULL THEN
	      pt_comision:=t_iax_detcomision();
	    END IF;

	    LOOP
	        FETCH cur INTO vsproduc, vttitulo, vtrotulo, vcactivi, vtactivi, vcgarant, vtgarant, vnivel, vccomisi, vfinivig, vcmodcom, vtmodcom, vpcomisi, vninialt, vnfinalt, ccriterio, ndesde, nhasta, tcriterio;

	        EXIT WHEN cur%NOTFOUND;

	        pt_comision.extend;

	        pt_comision(pt_comision.last):=ob_iax_detcomision();

	        IF vccomisi IS NOT NULL THEN
	          pt_comision(pt_comision.last).ccomisi:=vccomisi;
	        ELSE
	          pt_comision(pt_comision.last).ccomisi:=pccomisi;
	        END IF;

	        BEGIN
	            SELECT tcomisi
	              INTO pt_comision(pt_comision.last).tcomisi
	              FROM descomision
	             WHERE ccomisi=nvl(vccomisi, pccomisi) AND
	                   cidioma=pac_md_common.f_get_cxtidioma;
	        EXCEPTION
	            WHEN OTHERS THEN
	              pt_comision(pt_comision.last).tcomisi:=NULL;
	        END;

	        /*Bug 24905/131645 - 17/12/2012 - AMC*/
	        verror:=pac_comisiones.f_get_comisiondesglose(vcactivi, vcgarant, vccomisi, vcmodcom, vfinivig, vninialt, vsproduc, vnfinalt, vdesglose);

	        IF verror<>0 THEN
	          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);

	          RAISE e_object_error;
	        END IF;

	        IF vdesglose IS NULL  OR
	           vdesglose=0 THEN
	          pt_comision(pt_comision.last).pcomisi:=vpcomisi;

	          pt_comision(pt_comision.last).pdesglose:=0;
	        ELSE
	          pt_comision(pt_comision.last).pcomisi:=vdesglose;

	          pt_comision(pt_comision.last).pdesglose:=1;

	          IF vpcomisi<>vdesglose THEN
	            pt_comision(pt_comision.last).modificado:=1;
	          END IF;
	        END IF;

	        /*Fi Bug 24905/131645 - 17/12/2012 - AMC*/
	        pt_comision(pt_comision.last).sproduc:=vsproduc;

	        pt_comision(pt_comision.last).ttitulo:=vttitulo;

	        pt_comision(pt_comision.last).cactivi:=vcactivi;

	        pt_comision(pt_comision.last).tactivi:=vtactivi;

	        pt_comision(pt_comision.last).cgarant:=vcgarant;

	        pt_comision(pt_comision.last).tgarant:=vtgarant;

	        pt_comision(pt_comision.last).nivel:=vnivel;

	        /*p_tab_error(f_sysdate, f_user, 'MD_f_get_detalle_comision', 1, vfinivig, '');*/
	        pt_comision(pt_comision.last).finivig:=vfinivig;

	        pt_comision(pt_comision.last).ffinvig:=vffinvig;

	        pt_comision(pt_comision.last).cmodcom:=vcmodcom;

	        pt_comision(pt_comision.last).tmodcom:=vtmodcom;

	        /*pt_comision(pt_comision.LAST).pcomisi := vpcomisi;*/
	        pt_comision(pt_comision.last).ninialt:=vninialt;

	        pt_comision(pt_comision.last).nfinalt:=vnfinalt;

	        pt_comision(pt_comision.last).ccriterio:=ccriterio;

	        pt_comision(pt_comision.last).ndesde:=ndesde;

	        pt_comision(pt_comision.last).nhasta:=nhasta;

	        pt_comision(pt_comision.last).tcriterio:=tcriterio;
	    END LOOP;

	    CLOSE cur;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, verror);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1;
	END f_get_detalle_comision;
	FUNCTION f_set_detalle_comision(
			pccomisi	IN	NUMBER,
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pnivel	IN	NUMBER,
			pcmodcom	IN	NUMBER,
			pfinivig	IN	DATE,
			ppcomisi	IN	NUMBER,
			pninialt	IN	NUMBER,
			pnfinalt	IN	NUMBER,
			pccriterio	IN	NUMBER,
			pndesde	IN	NUMBER,
			pnhasta	IN	NUMBER,
			obcomision	IN	OUT OB_IAX_DETCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_md_comisiones.f_set_detalle_comision';
	  vparam      VARCHAR2(500):='parámetros - pccomisi=' || pccomisi ||
                                ',psproduc=' || psproduc ||
                                ',pcactivi=' || pcactivi ||
                                ',pcgarant=' || pcgarant ||
                                ',pnivel=' || pnivel ||
                                ',pcmodcom=' || pcmodcom ||
                                ',pfinivig=' || pfinivig ||
                                ',ppcomisi=' || ppcomisi ||
                                ',pninialt=' || pninialt ||
                                ',pnfinalt=' || pnfinalt ||
                                ',pccriterio=' || pccriterio ||
                                ',pndesde=' || pndesde ||
                                ',pnhasta='||pnhasta;
	  vpasexec    NUMBER(5):=1;
	  verror      NUMBER(8):=0;
	  vsproduc    NUMBER(6);
	  vttitulo    VARCHAR2(500);
	  vtrotulo    VARCHAR2(500);
	  vcactivi    NUMBER(4);
	  vtactivi    VARCHAR2(500);
	  vcgarant    NUMBER(4);
	  vtgarant    VARCHAR2(500);
	  vnivel      NUMBER(1); /* 1 productos, 2 actividad, 3 garantia*/
	  vfinivig    DATE;
	  vffinvig    DATE;
	  vcmodcom    NUMBER(1); /* Código de modalidad de la comisión*/
	  vtmodcom    VARCHAR2(500);
	  vcmodali    NUMBER;
	  vtcomisi    VARCHAR2(500);
	  vpcomisi    FLOAT; /* Porcentaje de comisión*/
	  vquery      VARCHAR2(4000);
	  vctipseg    NUMBER;
	  vccolect    NUMBER;
	  vcramo      NUMBER;
	  cur         SYS_REFCURSOR;
	  vninialt    NUMBER;
	  vnfinalt    NUMBER;
	  vccriterio  NUMBER;
	  vndesde     NUMBER;
	  vnhasta     NUMBER;
	BEGIN
	    /*p_tab_error(f_sysdate, f_user, 'MD_SETDETALLE', 0,
	                pccomisi || '#' || psproduc || '#' || pcactivi || '#' || pcgarant || '#'
	                || pnivel || '#' || pfinivig || '#' || ppcomisi || '#' || pninialt || '#'
	                || pnfinalt,
	                '');*/
	    obcomision.ccomisi:=pccomisi;

	    SELECT tcomisi
	      INTO obcomision.tcomisi
	      FROM descomision
	     WHERE ccomisi=pccomisi AND
	           cidioma=pac_md_common.f_get_cxtidioma;

	    vpasexec:=2;

	    obcomision.sproduc:=psproduc;

	    SELECT cramo,cmodali,ctipseg,ccolect
	      INTO vcramo, vcmodali, vctipseg, vccolect
	      FROM productos
	     WHERE sproduc=psproduc;

	    vpasexec:=3;

	    obcomision.ttitulo:=f_desproducto_t(vcramo, vcmodali, vctipseg, vccolect, 1, pac_md_common.f_get_cxtidioma);

	    vpasexec:=4;

	    obcomision.trotulo:=f_desproducto_t(vcramo, vcmodali, vctipseg, vccolect, 2, pac_md_common.f_get_cxtidioma);

	    vpasexec:=5;

	    obcomision.cactivi:=pcactivi;

	    IF pcactivi IS NOT NULL THEN
	      SELECT tactivi
	        INTO obcomision.tactivi
	        FROM activisegu
	       WHERE cidioma=pac_md_common.f_get_cxtidioma AND
	             cramo=vcramo AND
	             cactivi=pcactivi;

	      vpasexec:=6;
	    END IF;

	    IF pninialt IS NULL THEN
	      IF pcmodcom IN(2, 4) THEN
	        vninialt:=2;
	      ELSE
	        vninialt:=1;
	      END IF;
	    ELSE
	      vninialt:=pninialt;
	    END IF;

	    IF pnfinalt IS NULL THEN
	      IF pcmodcom IN(2, 4) THEN
	        vnfinalt:=99;
	      ELSE
	        vnfinalt:=1;
	      END IF;
	    ELSE
	      vnfinalt:=pnfinalt;
	    END IF;

	    vpasexec:=7;

	    obcomision.cgarant:=pcgarant;

	    obcomision.tgarant:=ff_desgarantia(pcgarant, pac_md_common.f_get_cxtidioma);

	    vpasexec:=8;

	    obcomision.nivel:=pnivel;

	    obcomision.finivig:=pfinivig;

	    obcomision.cmodcom:=pcmodcom;

	    obcomision.tmodcom:=ff_desvalorfijo(67, pac_md_common.f_get_cxtidioma, pcmodcom);

	    vpasexec:=9;

	    obcomision.pcomisi:=ppcomisi;

	    obcomision.ninialt:=vninialt;

	    obcomision.nfinalt:=vnfinalt;

	    obcomision.ccriterio:=pccriterio;

	    obcomision.ndesde:=pndesde;

	    obcomision.nhasta:=pnhasta;

	    obcomision.tcriterio:=ff_desvalorfijo(67, pac_md_common.f_get_cxtidioma, pccriterio);

	    /*p_tab_error(f_sysdate, f_user, 'MD_SETDETALLE', 1, 'Fi', '');*/
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, verror);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_set_detalle_comision;
	FUNCTION f_set_traspaso_detalle_obj_bd(
			t_detcomision	IN	T_IAX_DETCOMISION,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vobjectname VARCHAR2(500):='pac_iax_comisiones.f_set_traspaso_detalle_obj_bd';
	  vparam      VARCHAR2(500):='parámetros - ';
	  vpasexec    NUMBER(5):=1;
	  vnumerr     NUMBER(8):=0;
	  v_cont      NUMBER:=0;
	BEGIN
	    /*p_tab_error(f_sysdate, f_user, 'MD_SETDET_OBJ_BD', 0, 'INI', '');*/
	    IF t_detcomision IS NOT NULL AND
	       t_detcomision.count>0 THEN
	      FOR i IN t_detcomision.first .. t_detcomision.last LOOP
	          IF t_detcomision.EXISTS(i) THEN
	            IF t_detcomision(i).modificado=1 THEN
	              v_cont:=1;

	              vnumerr:=pac_comisiones.f_set_detalle_comision(t_detcomision(i).sproduc, t_detcomision(i).cactivi, t_detcomision(i).cgarant, t_detcomision(i).nivel, t_detcomision(i).finivig, t_detcomision(i).cmodcom, t_detcomision(i).ccomisi, t_detcomision(i).pcomisi, t_detcomision(i).ninialt, t_detcomision(i).nfinalt, t_detcomision(i).ccriterio, t_detcomision(i).ndesde, t_detcomision(i).nhasta);

	              IF vnumerr<>0 THEN
	                pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	                RAISE e_object_error;
	              END IF;
	            END IF;
	          END IF;
	      END LOOP;
	    END IF;

	    IF v_cont=0 THEN
	      /*p_tab_error(f_sysdate, f_user, 'MD_SETDET_OBJ_BD', 2, 'SENSE CANVIS', '');*/
	      RETURN -1; /*Comprobar que no se ha hecho ningún cambio*/
	    END IF;

	    /*p_tab_error(f_sysdate, f_user, 'MD_SETDET_OBJ_BD', 3, 'Fi', vnumerr);*/
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
	END f_set_traspaso_detalle_obj_bd;
	FUNCTION f_get_hist_cuadrocomision(
			pccomisi	IN	NUMBER,
			pdetcomision	OUT	T_IAX_CUADROCOMISION,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(4000):='PCCOMISI:'
	                         || pccomisi;
	  vobject  VARCHAR2(200):='PAC_MD_COMISIONES.f_get_hist_cuadrocomision';
	  vsquery  VARCHAR2(1000);
	  verror   NUMBER;
	  cur      SYS_REFCURSOR;
	  vccomisi NUMBER;
	  vtcomisi VARCHAR2(500);
	  vctipo   NUMBER;
	  vttipo   VARCHAR2(500);
	  vfinivig DATE;
	  vffinvig DATE;
	  vcestado NUMBER;
	BEGIN
	    verror:=pac_comisiones.f_get_hist_cuadrocomision(pccomisi, pac_md_common.f_get_cxtidioma, vsquery);

	    cur:=pac_md_listvalores.f_opencursor(vsquery, mensajes);

	    IF pdetcomision IS NULL THEN
	      pdetcomision:=t_iax_cuadrocomision();
	    END IF;

	    LOOP
	        FETCH cur INTO vccomisi, vtcomisi, vctipo, vfinivig, vffinvig, vcestado;

	        EXIT WHEN cur%NOTFOUND;

	        pdetcomision.extend;

	        pdetcomision(pdetcomision.last):=ob_iax_cuadrocomision();

	        pdetcomision(pdetcomision.last).ccomisi:=vccomisi;

	        pdetcomision(pdetcomision.last).tcomisi:=vtcomisi;

	        pdetcomision(pdetcomision.last).ctipo:=vctipo;

	        pdetcomision(pdetcomision.last).finivig:=vfinivig;

	        pdetcomision(pdetcomision.last).ffinvig:=vffinvig;

	        pdetcomision(pdetcomision.last).cestado:=vcestado;

	        pdetcomision(pdetcomision.last).ttipo:=ff_desvalorfijo(1015, pac_md_common.f_get_cxtidioma, vctipo);

	        pdetcomision(pdetcomision.last).testado:=ff_desvalorfijo(1016, pac_md_common.f_get_cxtidioma, vcestado);

	        verror:=pac_md_comisiones.f_get_desccomisiones (pccomisi, pdetcomision(pdetcomision.last).descripciones, mensajes);
	    END LOOP;

	    CLOSE cur;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1;
	END f_get_hist_cuadrocomision;

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
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec  NUMBER(8):=1;
	  vparam    VARCHAR2(4000):='psproduc:'
	                         || psproduc
	                         || ' pcactivi:'
	                         || pcactivi
	                         || ' pcgarant:'
	                         || pcgarant
	                         || ' pcnivel:'
	                         || pcnivel;
	  vobject   VARCHAR2(200):='PAC_MD_COMISIONES.f_get_porproducto';
	  vsquery   VARCHAR2(1000);
	  verror    NUMBER;
	  cur       SYS_REFCURSOR;
	  vccomisi  NUMBER;
	  vtcomisi  VARCHAR2(500);
	  vpcomisi  NUMBER;
	  vcmodcom  NUMBER;
	  vtmodcom  VARCHAR2(500);
	  vninialt  NUMBER;
	  vnfinalt  NUMBER;
	  vdesglose NUMBER;
	  vfinivig  DATE;
	  ccriterio NUMBER; /*msv*/
	  ndesde    NUMBER; /*msv*/
	  nhasta    NUMBER; /*msv*/
	  tcriterio VARCHAR(100); /*msv*/
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

	    verror:=pac_comisiones.f_get_porproducto(psproduc, pcactivi, pcgarant, pcnivel, pcfinivig, pac_md_common.f_get_cxtidioma, vsquery);

	    cur:=pac_md_listvalores.f_opencursor(vsquery, mensajes);

	    IF pt_comision IS NULL THEN
	      pt_comision:=t_iax_detcomision();
	    END IF;

	    LOOP
	        FETCH cur INTO vtcomisi, vccomisi, vpcomisi, vninialt, vnfinalt, vcmodcom, vtmodcom, vfinivig, ccriterio, ndesde, nhasta, tcriterio;

	        EXIT WHEN cur%NOTFOUND;

	        pt_comision.extend;

	        pt_comision(pt_comision.last):=ob_iax_detcomision();

	        pt_comision(pt_comision.last).ccomisi:=vccomisi;

	        pt_comision(pt_comision.last).tcomisi:=vtcomisi;

	        /* pt_comision(pt_comision.LAST).pcomisi := vpcomisi;*/
	        pt_comision(pt_comision.last).cmodcom:=vcmodcom;

	        pt_comision(pt_comision.last).tmodcom:=vtmodcom;

	        pt_comision(pt_comision.last).sproduc:=psproduc;

	        pt_comision(pt_comision.last).cactivi:=pcactivi;

	        pt_comision(pt_comision.last).cgarant:=pcgarant;

	        pt_comision(pt_comision.last).nivel:=pcnivel;

	        pt_comision(pt_comision.last).ninialt:=vninialt;

	        pt_comision(pt_comision.last).nfinalt:=vnfinalt;

	        /*Bug 24905/131645 - 17/12/2012 - AMC*/
	        pt_comision(pt_comision.last).finivig:=vfinivig;

	        /*Nuevos campos*/
	        pt_comision(pt_comision.last).ccriterio:=ccriterio;

	        pt_comision(pt_comision.last).ndesde:=ndesde;

	        pt_comision(pt_comision.last).nhasta:=nhasta;

	        pt_comision(pt_comision.last).tcriterio:=tcriterio;

	        verror:=pac_comisiones.f_get_comisiondesglose(pcactivi, pcgarant, vccomisi, vcmodcom, pcfinivig, vninialt, psproduc, vnfinalt, vdesglose);

	        IF verror<>0 THEN
	          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);

	          RAISE e_object_error;
	        END IF;

	        IF vdesglose IS NULL  OR
	           vdesglose=0 THEN
	          pt_comision(pt_comision.last).pcomisi:=vpcomisi;

	          pt_comision(pt_comision.last).pdesglose:=0;
	        ELSE
	          pt_comision(pt_comision.last).pcomisi:=vdesglose;

	          pt_comision(pt_comision.last).pdesglose:=1;

	          IF vpcomisi<>vdesglose THEN
	            pt_comision(pt_comision.last).modificado:=1;
	          END IF;
	        END IF;
	    /*Fi Bug 24905/131645 - 17/12/2012 - AMC*/
	    END LOOP;

	    CLOSE cur;

	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN 1;
	END f_get_porproducto;

	/****************************************************************
	Duplica el detalle de comisión apartir de un ccomisi y una fecha
	param in pccomisi   : codigo de comisión
	param in pfinivi   : Fecha de inicio de vigencia
	param out mensajes   : mensajes de error

	return : codigo de error
	*************************************************************************/
	FUNCTION f_dup_det_comision(
			pccomisi	IN	NUMBER,
			pfinivig	IN	DATE,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec    NUMBER(8):=1;
	  vparam      VARCHAR2(4000):='Param.: pccomisi:'
	                         || pccomisi
	                         || ' pfinivi:'
	                         || pfinivig;
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_dup_det_comision';
	  vnumerr     NUMBER:=0;
	BEGIN
	    IF pccomisi IS NULL  OR
	       pfinivig IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_comisiones.f_dup_det_comision(pccomisi, pfinivig);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
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
	END f_dup_det_comision;

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
	  cur      SYS_REFCURSOR;
	  vpasexec NUMBER(8):=1;
	  vparam   VARCHAR2(500):='paràmetres - psproduc: '
	                        || psproduc
	                        || ' - pctipo:'
	                        || pctipo;
	  vobject  VARCHAR2(200):='PAC_MD_COMISIONES.f_get_lsfechasvigencia';
	  vquery   VARCHAR2(2000);
	BEGIN
	    IF psproduc IS NULL  OR
	       pctipo IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    /*Productos*/
	    IF pctipo=1 THEN
	      vquery:='select distinct finivig from comisionprod'
	              || ' where (cramo, cmodali, ctipseg, ccolect) in'
	              || ' (select cramo, cmodali, ctipseg, ccolect'
	              || ' from productos where  sproduc = '
	              || psproduc
	              || ')'
	              || ' order by finivig';
	    ELSIF pctipo=2 THEN
	      /* ACTIVIDAD*/
	      vquery:='select distinct finivig from comisionacti'
	              || ' where (cramo, cmodali, ctipseg, ccolect) in'
	              || ' (select cramo, cmodali, ctipseg, ccolect'
	              || ' from productos where  sproduc = '
	              || psproduc
	              || ')'
	              || ' order by finivig';
	    ELSIF pctipo=3 THEN
	      /* ACTIVIDAD*/
	      vquery:='select distinct finivig from comisiongar'
	              || ' where (cramo, cmodali, ctipseg, ccolect) in'
	              || ' (select cramo, cmodali, ctipseg, ccolect'
	              || ' from productos where  sproduc = '
	              || psproduc
	              || ')'
	              || ' order by finivig';
	    ELSIF pctipo=4 THEN
	      vquery:='select distinct finivig from comisionprod'
	              || ' where (cramo, cmodali, ctipseg, ccolect) in'
	              || ' (select cramo, cmodali, ctipseg, ccolect'
	              || ' from productos where  sproduc = '
	              || psproduc
	              || ')'
	              || ' UNION';

	      /* ACTIVIDAD*/
	      vquery:=vquery
	              || ' select distinct finivig from comisionacti'
	              || ' where (cramo, cmodali, ctipseg, ccolect) in'
	              || ' (select cramo, cmodali, ctipseg, ccolect'
	              || ' from productos where  sproduc = '
	              || psproduc
	              || ')'
	              || ' UNION ';

	      vquery:=vquery
	              || ' select distinct finivig from comisiongar'
	              || ' where (cramo, cmodali, ctipseg, ccolect) in'
	              || ' (select cramo, cmodali, ctipseg, ccolect'
	              || ' from productos where  sproduc = '
	              || psproduc
	              || ')'
	              || ' order by finivig desc';
	    END IF;

	    /* Bug 0012822 - 09/02/2010 - JMF: Evitar que es puguin seleccionar les causes (3,4,5,8)*/
	    cur:=pac_md_listvalores.f_opencursor(vquery, mensajes);

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_get_lsfechasvigencia;

	/****************************************************************
	      Duplica el detalle de comisión apartir de un ccomisi y una fecha
	      param in pccomisi   : codigo de comisión
	      param in pfinivi   : Fecha de inicio de vigencia
	      param out mensajes   : mensajes de error

	      return : codigo de error
	   *************************************************************************/
	FUNCTION f_duplicar_cuadro_prod(
			pcsproduc	IN	NUMBER,
			pfinivig	IN	DATE,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec    NUMBER(8):=1;
	  vparam      VARCHAR2(4000):='Param.: pcsproduc:'
	                         || pcsproduc
	                         || ' pfinivig:'
	                         || pfinivig;
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_duplicar_cuadro_prod';
	  vnumerr     NUMBER:=0;
	BEGIN
	    IF pcsproduc IS NULL  OR
	       pfinivig IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_comisiones.f_duplicar_cuadro_prod(pcsproduc, pfinivig);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
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
	END f_duplicar_cuadro_prod;
	FUNCTION f_get_alturas(
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pccomisi	IN	NUMBER,
			pcmodcom	IN	NUMBER,
			pfinivig	IN	DATE,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  cur         SYS_REFCURSOR;
	  vpasexec    NUMBER(8):=1;
	  vparam      VARCHAR2(500):='paràmetres - psproduc: '
	                        || psproduc
	                        || ' - pcactivi:'
	                        || pcactivi;
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_get_alturas';
	  vquery      VARCHAR2(2000);
	  vnumerr     NUMBER;
	BEGIN
	    IF pcgarant IS NULL AND
	       pcactivi IS NULL THEN
	      vquery:='SELECT p.sproduc, t.ttitulo tproduc, a.cactivi, a.tactivi, g.cgarant, g.tgarant, dc.ccomisi,
		       dc.tcomisi, ff_desvalorfijo(67, t.cidioma, '
	              || pcmodcom
	              || ') tmodcom, c.pcomisi, c.ninialt, c.nfinalt
		  FROM productos p, titulopro t, activisegu a, garangen g, descomision dc, comisionprod c
		 WHERE p.sproduc = '
	              || psproduc
	              || ' AND p.cramo = t.cramo
		   AND p.cmodali = t.cmodali
		   AND p.ctipseg = t.ctipseg
		   AND p.ccolect = t.ctipseg
		   AND t.cidioma = pac_md_common.F_GET_CXTIDIOMA()
		   AND p.cramo = a.cramo(+)
		   AND a.cidioma(+) = pac_md_common.F_GET_CXTIDIOMA()
		   AND a.cactivi(+) = '
	              || nvl(pcactivi, 'NULL')
	              || ' AND g.cgarant(+) = '
	              || nvl(pcgarant, 'NULL')
	              || ' AND g.cidioma(+) = t.cidioma
		   AND dc.ccomisi = '
	              || pccomisi
	              || ' AND dc.cidioma = t.cidioma
		   and c.CCOMISI(+) = '
	              || pccomisi
	              || ' and c.SPRODUC(+) = p.sproduc
		   and c.FINIVIG(+) = to_date('''
	              || to_char(pfinivig, 'dd/mm/yyyy')
	              || ''',''dd/mm/yyyy'')';
	    ELSIF pcgarant IS NULL THEN
	      vquery:='SELECT p.sproduc, t.ttitulo tproduc, a.cactivi, a.tactivi, g.cgarant, g.tgarant, dc.ccomisi,
		       dc.tcomisi, ff_desvalorfijo(67, t.cidioma, '
	              || pcmodcom
	              || ') tmodcom, c.pcomisi, c.ninialt, c.nfinalt
		  FROM productos p, titulopro t, activisegu a, garangen g, descomision dc, comisionacti c
		 WHERE p.sproduc = '
	              || psproduc
	              || ' AND p.cramo = t.cramo
		   AND p.cmodali = t.cmodali
		   AND p.ctipseg = t.ctipseg
		   AND p.ccolect = t.ctipseg
		   AND t.cidioma = pac_md_common.F_GET_CXTIDIOMA()
		   AND p.cramo = a.cramo(+)
		   AND a.cidioma(+) = pac_md_common.F_GET_CXTIDIOMA()
		   AND a.cactivi(+) = '
	              || nvl(pcactivi, 'NULL')
	              || ' AND g.cgarant(+) = '
	              || nvl(pcgarant, 'NULL')
	              || ' AND g.cidioma(+) = t.cidioma
		   AND dc.ccomisi = '
	              || pccomisi
	              || ' AND dc.cidioma = t.cidioma
		   and c.CCOMISI(+) = '
	              || pccomisi
	              || ' and c.SPRODUC(+) = p.sproduc
		            and c.cactivi(+) = '
	              || pcactivi
	              || ' and c.FINIVIG(+) = to_date('''
	              || to_char(pfinivig, 'dd/mm/yyyy')
	              || ''',''dd/mm/yyyy'')';
	    ELSE
	      vquery:='SELECT p.sproduc, t.ttitulo tproduc, a.cactivi, a.tactivi, g.cgarant, g.tgarant, dc.ccomisi,
		       dc.tcomisi, ff_desvalorfijo(67, t.cidioma, '
	              || pcmodcom
	              || ') tmodcom, c.pcomisi, c.ninialt, c.nfinalt
		  FROM productos p, titulopro t, activisegu a, garangen g, descomision dc, comisiongar c
		 WHERE p.sproduc = '
	              || psproduc
	              || ' AND p.cramo = t.cramo
		   AND p.cmodali = t.cmodali
		   AND p.ctipseg = t.ctipseg
		   AND p.ccolect = t.ctipseg
		   AND t.cidioma = pac_md_common.F_GET_CXTIDIOMA()
		   AND p.cramo = a.cramo(+)
		   AND a.cidioma(+) = pac_md_common.F_GET_CXTIDIOMA()
		   AND a.cactivi(+) = '
	              || nvl(pcactivi, 'NULL')
	              || ' AND g.cgarant(+) = '
	              || nvl(pcgarant, 'NULL')
	              || ' AND g.cidioma(+) = t.cidioma
		   AND dc.ccomisi = '
	              || pccomisi
	              || ' AND dc.cidioma = t.cidioma
		   and c.CCOMISI(+) = '
	              || pccomisi
	              || ' and c.SPRODUC(+) = p.sproduc
		            and c.cactivi(+) = '
	              || pcactivi
	              || ' and c.cgarant(+) = '
	              || pcgarant
	              || ' and c.FINIVIG(+) = to_date('''
	              || to_char(pfinivig, 'dd/mm/yyyy')
	              || ''',''dd/mm/yyyy'')';
	    END IF;

	    cur:=pac_md_listvalores.f_opencursor(vquery, mensajes);

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN NULL; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN NULL; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_get_alturas;
	FUNCTION f_del_altura(
			psproduc	IN	NUMBER,
			pcactivi	IN	NUMBER,
			pcgarant	IN	NUMBER,
			pccomisi	IN	NUMBER,
			pcmodcom	IN	NUMBER,
			pfinivig	IN	DATE,
			pninialt	IN	NUMBER,
			pnivel	IN	NUMBER,
			pccriterio	IN	NUMBER,
			pnhasta	IN	NUMBER,
			pndesde	IN	NUMBER,
			mensajes	IN	OUT T_IAX_MENSAJES
	) RETURN NUMBER
	IS
	  vpasexec    NUMBER(8):=1;
	  vparam      VARCHAR2(500):='paràmetres - psproduc: '
	                        || psproduc
	                        || ' - pcactivi:'
	                        || pcactivi
	                        || ' - '
	                        || pnivel
	                        || ' - '
	                        || pccriterio;
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_del_altura';
	  vquery      VARCHAR2(2000);
	  vnumerr     NUMBER;
	  vcount      NUMBER;
	BEGIN
	    IF pccriterio IS NULL THEN
	      IF pnivel=1 THEN
	        DELETE comisionprod
	         WHERE sproduc=psproduc AND
	               ccomisi=pccomisi AND
	               cmodcom=pcmodcom AND
	               finivig=pfinivig AND
	               ninialt=pninialt;
	      ELSIF pnivel=2 THEN
	        DELETE comisionacti
	         WHERE sproduc=psproduc AND
	               cactivi=pcactivi AND
	               ccomisi=pccomisi AND
	               cmodcom=pcmodcom AND
	               finivig=pfinivig AND
	               ninialt=pninialt;
	      ELSE
	        DELETE comisiongar
	         WHERE sproduc=psproduc AND
	               cactivi=pcactivi AND
	               cgarant=pcgarant AND
	               ccomisi=pccomisi AND
	               cmodcom=pcmodcom AND
	               finivig=pfinivig AND
	               ninialt=pninialt;
	      END IF;
	    ELSE
	      IF pnivel=1 THEN
	        DELETE comisionprod_criterio
	         WHERE (ctipseg, ccolect, cramo, cmodali)=(SELECT ctipseg,ccolect,cramo,cmodali
	                                                     FROM productos
	                                                    WHERE sproduc=psproduc) AND
	               ccomisi=pccomisi AND
	               cmodcom=pcmodcom AND
	               finivig=pfinivig AND
	               ninialt=pninialt AND
	               ndesde=pndesde AND
	               nhasta=pnhasta AND
	               ccriterio=pccriterio;

	        SELECT count(1)
	          INTO vcount
	          FROM comisionprod_criterio
	         WHERE (ctipseg, ccolect, cramo, cmodali)=(SELECT ctipseg,ccolect,cramo,cmodali
	                                                     FROM productos
	                                                    WHERE sproduc=psproduc) AND
	               ccomisi=pccomisi AND
	               cmodcom=pcmodcom AND
	               finivig=pfinivig AND
	               ninialt=pninialt;

	        IF vcount=0 THEN
	          DELETE comisionprod
	           WHERE sproduc=psproduc AND
	                 ccomisi=pccomisi AND
	                 cmodcom=pcmodcom AND
	                 finivig=pfinivig AND
	                 ninialt=pninialt;
	        END IF;
	      ELSIF pnivel=2 THEN
	        DELETE comisionacti_criterio
	         WHERE (ctipseg, ccolect, cramo, cmodali)=(SELECT ctipseg,ccolect,cramo,cmodali
	                                                     FROM productos
	                                                    WHERE sproduc=psproduc) AND
	               ccomisi=pccomisi AND
	               cmodcom=pcmodcom AND
	               finivig=pfinivig AND
	               ninialt=pninialt AND
	               ndesde=pndesde AND
	               nhasta=pnhasta AND
	               ccriterio=pccriterio;

	        SELECT count(1)
	          INTO vcount
	          FROM comisionacti_criterio
	         WHERE (ctipseg, ccolect, cramo, cmodali)=(SELECT ctipseg,ccolect,cramo,cmodali
	                                                     FROM productos
	                                                    WHERE sproduc=psproduc) AND
	               ccomisi=pccomisi AND
	               cmodcom=pcmodcom AND
	               finivig=pfinivig AND
	               ninialt=pninialt;

	        IF vcount=0 THEN
	          DELETE comisionacti
	           WHERE sproduc=psproduc AND
	                 cactivi=pcactivi AND
	                 ccomisi=pccomisi AND
	                 cmodcom=pcmodcom AND
	                 finivig=pfinivig AND
	                 ninialt=pninialt;
	        END IF;
	      ELSE
	        DELETE comisiongar_criterio
	         WHERE (ctipseg, ccolect, cramo, cmodali)=(SELECT ctipseg,ccolect,cramo,cmodali
	                                                     FROM productos
	                                                    WHERE sproduc=psproduc) AND
	               ccomisi=pccomisi AND
	               cmodcom=pcmodcom AND
	               finivig=pfinivig AND
	               ninialt=pninialt AND
	               ndesde=pndesde AND
	               nhasta=pnhasta AND
	               ccriterio=pccriterio;

	        SELECT count(1)
	          INTO vcount
	          FROM comisiongar_criterio
	         WHERE (ctipseg, ccolect, cramo, cmodali)=(SELECT ctipseg,ccolect,cramo,cmodali
	                                                     FROM productos
	                                                    WHERE sproduc=psproduc) AND
	               ccomisi=pccomisi AND
	               cmodcom=pcmodcom AND
	               finivig=pfinivig AND
	               ninialt=pninialt;

	        IF vcount=0 THEN
	          DELETE comisiongar
	           WHERE sproduc=psproduc AND
	                 cactivi=pcactivi AND
	                 cgarant=pcgarant AND
	                 ccomisi=pccomisi AND
	                 cmodcom=pcmodcom AND
	                 finivig=pfinivig AND
	                 ninialt=pninialt;
	        END IF;
	      END IF;
	    END IF;

	    /*p_tab_error(f_sysdate, f_user, vobjectname, 1, 'termine de pm', '');*/
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             RETURN 1; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam, vnumerr);

	             RETURN 1; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
	END f_del_altura;

	/*************************************************************************
	   Inserta el desglose del % de comision
	   param in pcactivi     Código de la actividad
	   param in pcgarant     Código de la garantia
	   param in pccomisi     Código comisión
	   param in pcmodcom     Código de la modalidad de comisión
	   param in pfinivig     Fecha inicio vigencia comisión
	   param in pninialt     Inicio de la altura
	   param in pcconcepto   Código concepto
	   param in ppcomisi     Porcentaje de comisión
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
			pcconcepto	IN	NUMBER,
			ppcomisi	IN	NUMBER,
			psproduc	IN	NUMBER,
			pnfinalt	IN	NUMBER,
			mensajes	IN	OUT T_IAX_MENSAJES
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
	                         || ' pcconcepto:'
	                         || pcconcepto
	                         || ' ppcomisi:'
	                         || ppcomisi
	                         || ' psproduc:'
	                         || psproduc
	                         || ' pnfinalt:'
	                         || pnfinalt;
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_set_comisiondesglose';
	BEGIN
	    vpasexec:=1;

	    vnumerr:=pac_comisiones.f_set_comisiondesglose(pcactivi, pcgarant, pccomisi, pcmodcom, pfinivig, pninialt, pcconcepto, ppcomisi, psproduc, pnfinalt);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
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
			mensajes	IN	OUT T_IAX_MENSAJES
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
	  vsquery     VARCHAR2(1000);
	  vcramo      NUMBER;
	  vcmodali    NUMBER;
	  vctipseg    NUMBER;
	  vccolect    NUMBER;
	  cur         SYS_REFCURSOR;
	BEGIN
	    vpasexec:=1;

	    IF psproduc IS NULL  OR
	       pccomisi IS NULL  OR
	       pcmodcom IS NULL  OR
	       pninialt IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    SELECT cramo,cmodali,ctipseg,ccolect
	      INTO vcramo, vcmodali, vctipseg, vccolect
	      FROM productos
	     WHERE sproduc=psproduc;

	    IF pcactivi IS NOT NULL AND
	       pcgarant IS NOT NULL THEN
	      vsquery:='select catribu,tatribu,pcomisi from detvalores d, comisiongar_concep c'
	               || ' where d.CVALOR = 8000911'
	               || ' and cidioma = '
	               || pac_md_common.f_get_cxtidioma()
	               || ' and d.CATRIBU = c.CCONCEPTO(+)'
	               || ' and cramo(+) = '
	               || vcramo
	               || ' and cmodali(+) = '
	               || vcmodali
	               || ' and ctipseg(+) = '
	               || vctipseg
	               || ' and ccolect(+) = '
	               || vccolect
	               || ' and cactivi(+) = '
	               || pcactivi
	               || ' and cgarant(+) = '
	               || pcgarant
	               || ' and ccomisi(+) = '
	               || pccomisi
	               || ' and cmodcom(+) = '
	               || pcmodcom
	               || ' and ninialt(+) = '
	               || pninialt;

	      IF pfinivig IS NOT NULL THEN
	        vsquery:=vsquery
	                 || ' and finivig(+) = to_date('''
	                 || to_char(pfinivig, 'dd/mm/yyyy')
	                 || ''',(''dd/mm/yyyy''))';
	      END IF;

	      vsquery:=vsquery
	               || ' order by catribu desc';
	    ELSIF pcactivi IS NOT NULL THEN
	      vsquery:='select catribu,tatribu,pcomisi from detvalores d, comisionacti_concep c'
	               || ' where d.CVALOR = 8000911'
	               || ' and cidioma = '
	               || pac_md_common.f_get_cxtidioma()
	               || ' and d.CATRIBU = c.CCONCEPTO(+)'
	               || ' and cramo(+) = '
	               || vcramo
	               || ' and cmodali(+) = '
	               || vcmodali
	               || ' and ctipseg(+) = '
	               || vctipseg
	               || ' and ccolect(+) = '
	               || vccolect
	               || ' and cactivi(+) = '
	               || pcactivi
	               || ' and ccomisi(+) = '
	               || pccomisi
	               || ' and cmodcom(+) = '
	               || pcmodcom
	               || ' and ninialt(+) = '
	               || pninialt;

	      IF pfinivig IS NOT NULL THEN
	        vsquery:=vsquery
	                 || ' and finivig(+) = to_date('''
	                 || to_char(pfinivig, 'dd/mm/yyyy')
	                 || ''',(''dd/mm/yyyy''))';
	      END IF;

	      vsquery:=vsquery
	               || ' order by catribu desc';
	    ELSE
	      vsquery:='select catribu,tatribu,pcomisi from detvalores d, comisionprod_concep c'
	               || ' where d.CVALOR = 8000911'
	               || ' and cidioma = '
	               || pac_md_common.f_get_cxtidioma()
	               || ' and d.CATRIBU = c.CCONCEPTO(+)'
	               || ' and cramo(+) = '
	               || vcramo
	               || ' and cmodali(+) = '
	               || vcmodali
	               || ' and ctipseg(+) = '
	               || vctipseg
	               || ' and ccolect(+) = '
	               || vccolect
	               || ' and ccomisi(+) = '
	               || pccomisi
	               || ' and cmodcom(+) = '
	               || pcmodcom
	               || ' and ninialt(+) = '
	               || pninialt;

	      IF pfinivig IS NOT NULL THEN
	        vsquery:=vsquery
	                 || ' and finivig(+) = to_date('''
	                 || to_char(pfinivig, 'dd/mm/yyyy')
	                 || ''',(''dd/mm/yyyy''))';
	      END IF;

	      vsquery:=vsquery
	               || ' order by catribu desc';
	    END IF;

	    cur:=pac_md_listvalores.f_opencursor(vsquery, mensajes);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

	      RAISE e_object_error;
	    END IF;

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
			mensajes	IN	OUT T_IAX_MENSAJES
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

	    vnumerr:=pac_comisiones.f_del_comisiondesglose(pcactivi, pcgarant, pccomisi, pcmodcom, pfinivig, pninialt, psproduc, pnfinalt);

	    IF vnumerr<>0 THEN
	      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);

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

	    SELECT max(finivig)
	      INTO vfecha
	      FROM comisionprod
	     WHERE ccomisi=pccomisi;

	    RETURN vfecha;
	EXCEPTION
	  WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN NULL;
	END f_get_fechavigencia;

	/*************************************************************************
	 Inserta el parà metre per porcentaje de retrocesiòn
	 param in pnempres     : Código empresa
	 param in pnmesi      : Mes inicial
	 param in pnmesf     : Mes final
	 param in pnanulac  : Porcentaje de retrocesiòn
	 return              : 0.- OK, 1.- KO
	 *************************************************************************/
	FUNCTION f_ins_confclawback(
			pnempres	IN	NUMBER,
			pnmesi	IN	NUMBER,
			pnmesf	IN	NUMBER,
			pnanulac	IN	NUMBER,
			mensajes	IN	OUT T_IAX_MENSAJES
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
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_ins_confclawback';
	BEGIN
	    IF pnempres IS NULL  OR
	       pnmesi IS NULL  OR
	       pnmesf IS NULL  OR
	       pnanulac IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_comisiones.f_ins_confclawback(pnempres, pnmesi, pnmesf, pnanulac, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9908042; /*Error en inserir a la taula CLAWBACK_CONF*/
	END f_ins_confclawback;

	/*************************************************************************
	   Actualitzar  el parà metre per porcentaje de retrocesiòn
	   param in pnempres     : Código empresa
	   param in pnmesi      : Mes inicial
	   param in pnmesf     : Mes final
	   param in pnanulac  : Porcentaje de retrocesiòn
	   return              : 0.- OK, 1.- KO
	   *************************************************************************/
	FUNCTION f_upd_confclawback(
			pnempres	IN	NUMBER,
			pnmesi_old	IN	NUMBER,
			pnmesi_new	IN	NUMBER,
			pnmesf_old	IN	NUMBER,
			pnmesf_new	IN	NUMBER,
			pnanulac_old	IN	NUMBER,
			pnanulac_new	IN	NUMBER,
			mensajes	IN	OUT T_IAX_MENSAJES
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
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_upd_confclawback';
	BEGIN
	    IF pnempres IS NULL  OR
	       pnmesi_old IS NULL  OR
	       pnmesf_old IS NULL  OR
	       pnanulac_old IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_comisiones.f_upd_confclawback(pnempres, pnmesi_old, pnmesi_new, pnmesf_old, pnmesf_new, pnanulac_old, pnanulac_new, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9908043; /*Error en actualitzar a la taula CLAWBACK_CONF*/
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
			mensajes	IN	OUT T_IAX_MENSAJES
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
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_del_confclawback ';
	BEGIN
	    IF pnempres IS NULL  OR
	       pnmesi IS NULL  OR
	       pnmesf IS NULL  OR
	       pnanulac IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vnumerr:=pac_comisiones.f_del_confclawback(pnempres, pnmesi, pnmesf, pnanulac, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    RETURN 0;
	EXCEPTION
	  WHEN OTHERS THEN
	             p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam, 'SQLERROR: '
	                                                                           || SQLCODE
	                                                                           || ' - '
	                                                                           || SQLERRM);

	             RETURN 9908044; /*Error en esborrar en la taula CLAWBACK_CONF*/
	END f_del_confclawback;

	/*************************************************************************
	 Consulta dades de la taula CLAWBACK_CONF
	 param in pnempres     : Código empresa
	 param in pnmesi      : Mes inicial
	 param in pnmesf     : Mes final
	 param in pnanulac  : Porcentaje de retrocesiòn
	 return              : 0.- OK, 1.- KO
	 *************************************************************************/
	FUNCTION f_get_confclawback(
			pnempres	IN	NUMBER,
			pnmesi	IN	NUMBER,
			pnmesf	IN	NUMBER,
			pnanulac	IN	NUMBER,
			mensajes	OUT	T_IAX_MENSAJES
	) RETURN SYS_REFCURSOR
	IS
	  cur         SYS_REFCURSOR;
	  vnumerr     NUMBER(8):=0;
	  vpasexec    NUMBER(8):=1;
	  vparam      VARCHAR2(500):='parámetros  - pnempres: '
	                        || pnempres
	                        || ' - pnmesi: '
	                        || pnmesi
	                        || ' - pnmesf: '
	                        || pnmesf
	                        || ' - pnanulac: '
	                        || pnanulac;
	  vobjectname VARCHAR2(200):='PAC_MD_COMISIONES.f_get_confclawback ';
	  vsquery     VARCHAR2(1000);
	BEGIN
	    IF pnempres IS NULL THEN
	      RAISE e_param_error;
	    END IF;

	    vsquery:=' SELECT CEMPRES,NMES_I,NMES_F,PANULAC'
	             || ' FROM CLAWBACK_CONF'
	             || ' WHERE CEMPRES ='
	             || pnempres;

	    IF pnmesi IS NOT NULL THEN
	      vsquery:=vsquery
	               || ' AND NMES_I = '
	               || pnmesi;
	    END IF;

	    IF pnmesf IS NOT NULL THEN
	      vsquery:=vsquery
	               || ' AND NMES_F = '
	               || pnmesf;
	    END IF;

	    IF pnanulac IS NOT NULL THEN
	      vsquery:=vsquery
	               || ' AND PANULAC = '
	               || pnanulac;
	    END IF;

	    vsquery:=vsquery
	             || ' order by nmes_i';

	    cur:=pac_comisiones.f_get_confclawback(vsquery, mensajes);

	    RETURN cur;
	EXCEPTION
	  WHEN e_param_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur; WHEN e_object_error THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur; WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN cur;
	END f_get_confclawback;
	/*************************************************************************
	Consulta comision habitual por agente
	param in pcagente     : Código Agente
	param in psproduc      : Producto
	param in pramo     : Ramo
	param in pfefecto     : Fecha de efecto
	return              : v_pcomisi - OK, 0.- KO
	*************************************************************************/
	FUNCTION f_get_comsis_agente(pcagente IN agentes.cagente%TYPE,
								 psproduc IN seguros.sproduc%TYPE,
								 pramo    IN NUMBER,
								 pfefecto in date,
								 mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS
	  vobject   VARCHAR2(200) := 'PAC_MD_PRODUCCION.f_get_comsis_agente';
	  vparam    VARCHAR2(500) := 'pcagente=' || pcagente || ' psproduc=' ||
								 psproduc || ' pramo=' || pramo || ' pfefecto=' ||
								 to_char(pfefecto, 'DD/MM/YYYY');
	  v_pcomisi number := 0;
	  vpasexec  number := 1;
	  v_nerr    number := 0;
	BEGIN
	  IF pcagente IS NULL OR psproduc IS NULL OR pramo IS NULL OR
		 pfefecto IS NULL THEN
		vpasexec := 10;
		raise e_param_error;
	  END IF;

	  BEGIN
		SELECT MIN(pcomisi)
		  INTO v_pcomisi
		  FROM comisionprod c, agentes a
		 WHERE c.sproduc = psproduc
		   AND c.ccomisi = a.ccomisi
		   AND a.cagente = pcagente
		   ANd c.cramo = pramo
		   AND c.finivig = (SELECT MAX(finivig)
							  FROM comisionvig v
							 WHERE v.ccomisi = a.ccomisi
							   AND v.finivig <= pfefecto);

		vpasexec := 20;
	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  vpasexec := 30;
		  v_nerr   := 100933;
		  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nerr);
		  v_pcomisi := 0;
	  END;

	  RETURN v_pcomisi;
	EXCEPTION
	  WHEN e_param_error THEN
		pac_iobj_mensajes.p_tratarmensaje(mensajes,
										  vobject,
										  1000005,
										  vpasexec,
										  vparam);
		RETURN 0;
	  WHEN e_object_error THEN
		pac_iobj_mensajes.p_tratarmensaje(mensajes,
										  vobject,
										  1000006,
										  vpasexec,
										  vparam);
		RETURN 0;
	  WHEN OTHERS THEN
		pac_iobj_mensajes.p_tratarmensaje(mensajes,
										  vobject,
										  1000001,
										  vpasexec,
										  vparam,
										  psqcode  => SQLCODE,
										  psqerrm  => SQLERRM);
		RETURN 0;
	END f_get_comsis_agente;


	/*************************************************************************
	Recupera  los datos de cuadros de comisiones ya existentes
	param in ccomisi     : Código de comision
	return               : Numero de codigo de comision
	*************************************************************************/
	FUNCTION f_valida_cuadro(
      pccomisi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pccomisi:' || pccomisi;
      vobject        VARCHAR2(200) := 'PAC_MD_COMISIONES.f_valida_cuadro';
      verror         NUMBER;
   BEGIN
      IF pccomisi IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_comisiones.f_valida_cuadro(pccomisi);

      RETURN verror;
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
         RETURN null;
   END f_valida_cuadro;


	/*************************************************************************
	Elimina  los datos del cuadro de comision elegido
	param in ccomisi     : Código de comision
	return               : Mensaje de error
	*************************************************************************/
      FUNCTION f_anular_cuadro(
      pccomisi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pccomisi = ' || pccomisi;
      vobject        VARCHAR2(200) := 'PAC_MD_COMISIONES.F_ANULAR_CUADRO';
   BEGIN
      vpasexec := 1;
      IF pccomisi IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_comisiones.f_anular_cuadro(pccomisi);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_anular_cuadro;

END pac_md_comisiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_COMISIONES" TO "PROGRAMADORESCSI";
