CREATE OR REPLACE PACKAGE BODY pac_md_rango_dian IS

   /******************************************************************************
      NOMBRE:     pac_md_rango_dian
      PROPÓSITO:  Funciones rango dian

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        26/08/2016   FOR               1. Creación del package.
      2.0        19/06/2019   JLTS              2. Se incluye esta columna SPRODUC en f_set_versionesdian
   ******************************************************************************/

	/*************************************************************************
	Recupera Versiones Dian

	*************************************************************************/
	FUNCTION f_get_versionesdian(
		psrdian IN NUMBER,
			 presolucion	IN	NUMBER,
			 psucursal	  IN	NUMBER,
			 pcgrupo	    IN	VARCHAR2,
       pdescrip	    IN	VARCHAR2,
       pusuario	    IN	VARCHAR2,
       PMAIL  	    in	number,
       PCACTIVI IN NUMBER,
       pcramo   IN NUMBER,
       PTESTADO  	    in	number,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR
	IS
	  vpasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000);
	  vobjectname VARCHAR2(200):='pac_md_rango_dian.f_get_versionesdian';
	  cur         SYS_REFCURSOR;
	BEGIN
	    vpasexec:=1;



	    cur := PAC_RANGO_DIAN.f_get_versionesdian(psrdian, presolucion, psucursal, pcgrupo, pdescrip, pusuario, pmail, PCACTIVI,pcramo,PTESTADO,  mensajes);

	    RETURN cur;
	EXCEPTION
	  WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN NULL;
	END f_get_versionesdian;

  FUNCTION f_set_versionesdian(
		psrdian  IN NUMBER,
			  pnresol    IN NUMBER,
        pcagente   IN NUMBER,
        pcgrupo   IN VARCHAR2,
        pfresol    IN DATE,
        pfinivig   IN DATE,
        pffinvig   IN DATE,
        ptdescrip  IN VARCHAR2,
        pninicial  IN NUMBER,
        pnfinal    IN NUMBER,
        pcusu      IN VARCHAR2,
        ptestado   IN VARCHAR2,
        pcenvcorr  IN VARCHAR2,
        pnaviso    IN NUMBER,
        pncertavi  IN NUMBER,
        pncontador IN NUMBER,
        PMODO      in varchar2,
        PCACTIVI IN NUMBER,
        pcramo IN    NUMBER,
        psproduc IN NUMBER, --IAXIS-3288 -JLTS -19/06/2019. Se incluye esta columna
			  mensajes	 OUT	T_IAX_MENSAJES
	)   RETURN NUMBER
   IS
	  vpasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000);
	  vobjectname VARCHAR2(200):='pac_md_rango_dian.f_set_versionesdian';
		vmensa      VARCHAR2(1000);

	BEGIN
      vpasexec:=1;


	    vnumerr := PAC_RANGO_DIAN.f_set_versionesdian( psrdian,pnresol,
        pcagente,
        pcgrupo,
        pfresol,
        pfinivig,
        pffinvig,
        ptdescrip,
        pninicial,
        pnfinal,
        pcusu,
        ptestado,
        pcenvcorr,
        pnaviso,
        pncertavi,
        pncontador,
        PMODO,
        PCACTIVI,
        pcramo,
        psproduc,
			  mensajes);

				if vnumerr <> 0 THEN
					vmensa := pac_iobj_mensajes.f_get_descmensaje(9909567,pac_md_common.f_get_cxtidioma);
					pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 0,vmensa);
				END IF;
				p_control_error('JLTS',vobjectname,'Se realizan los ajustes ='||pcenvcorr);
        COMMIT;

	    RETURN vnumerr;

	EXCEPTION
        WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             RETURN 1;
  END f_set_versionesdian;

	FUNCTION f_get_gruposdian(
			 mensajes	IN OUT	T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR IS
	  vpasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000);
	  vobjectname VARCHAR2(200):='pac_md_rango_dian.f_get_gruposdian';
	  cur         SYS_REFCURSOR;
    vsquery     VARCHAR2(2000);
	BEGIN
	    vpasexec:=1;

	    vsquery := PAC_RANGO_DIAN.f_get_gruposdian();
      cur:=pac_md_listvalores.f_opencursor(vsquery, mensajes);

	    RETURN cur;
	EXCEPTION
	  WHEN OTHERS THEN
	             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

	             RETURN NULL;
	END f_get_gruposdian;
END pac_md_rango_dian;
/
