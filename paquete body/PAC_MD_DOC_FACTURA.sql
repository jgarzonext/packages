--------------------------------------------------------
--  DDL for Package Body PAC_MD_DOC_FACTURA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_DOC_FACTURA" AS

/******************************************************************************
   NOMBRE:      PAC_MD_DOC_FACTURA
   PROP¿SITO: Nuevo package con las funciones que se utilizan en las impresiones.
   En este package principalmente se utilizar¿ para funciones de validaci¿n de si un documento se imprime o no.

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
    1.0        18/03/2015   FFO                1. CREACION
******************************************************************************/

	FUNCTION  F_GET_FACTURA(
			 pusuario	    IN	VARCHAR2,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR
  IS
    pasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000);
	  vobjectname VARCHAR2(200):='PAC_MD_DOC_FACTURA .F_DOC_FACTURA';

    vsquery     VARCHAR2(5000);
	  cur         SYS_REFCURSOR;
    vpasexec    NUMBER;



  BEGIN

    cur := PAC_DOC_FACTURA.F_GET_FACTURA(pusuario,mensajes);

    RETURN cur;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname,1000005, vpasexec , vparam);

      RETURN NULL;

    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000006, vpasexec , vparam);

      RETURN NULL;

    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000001, vpasexec , vparam, NULL,SQLCODE,SQLERRM);

      RETURN NULL;

  END F_GET_FACTURA;

  FUNCTION   F_SET_FACTURA(
			  pdocfactura	    IN NUMBER,
        pnsinies	      IN NUMBER,
        pndocumento	    IN VARCHAR2,
        pdescripcion	  IN VARCHAR2,
        pfreclamacion	  IN DATE,
        pfrecepcion	    IN DATE,
        piddoc_imp	    IN NUMBER,
        peanulacion	    IN NUMBER,
        pcusualt	      IN VARCHAR2,
			  mensajes	      OUT	T_IAX_MENSAJES
	)   RETURN NUMBER
  IS

    pasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000);
	  vobjectname VARCHAR2(200):='PAC_MD_DOC_FACTURA .F_SET_FACTURA';
    vpasexec    NUMBER;
    num_err     NUMBER;



  BEGIN

    num_err := PAC_DOC_FACTURA.F_SET_FACTURA(pdocfactura, pnsinies, pndocumento, pdescripcion, pfreclamacion, pfrecepcion,
                                                piddoc_imp, peanulacion, pcusualt, mensajes);

    IF  num_err != 0 THEN
      RETURN 1;
    END IF;

    RETURN 0;
  EXCEPTION
      WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000005, vpasexec , vparam);

      RETURN NULL;

      WHEN e_object_error THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000006, vpasexec , vparam);

        RETURN NULL;

      WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000001, vpasexec , vparam, NULL,SQLCODE,SQLERRM);

        RETURN NULL;
  END F_SET_FACTURA;


  FUNCTION   F_ANULA_FACTURA(
			  pdocfactura	    IN NUMBER,
        pnsinies	      IN NUMBER,
			  mensajes	      OUT	T_IAX_MENSAJES
	)   RETURN NUMBER IS


    pasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000);
	  vobjectname VARCHAR2(200):='PAC_MD_DOC_FACTURA .F_ANULA_FACTURA';
    vpasexec    NUMBER;
    num_err     NUMBER;
  BEGIN

    num_err := PAC_DOC_FACTURA.F_ANULA_FACTURA(pdocfactura, pnsinies, mensajes);

    IF  num_err != 0 THEN
      RETURN 1;
    END IF;

    RETURN 0;

  EXCEPTION
      WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000005, vpasexec , vparam);

      RETURN NULL;

      WHEN e_object_error THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000006, vpasexec , vparam);

        RETURN NULL;

      WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000001, vpasexec , vparam, NULL,SQLCODE,SQLERRM);

        RETURN NULL;
  END F_ANULA_FACTURA;



  FUNCTION   F_VALIDA_FACTURA(
			  finicio	        IN DATE,
        ffin    	      IN DATE,
        vcagente         IN NUMBER,
			  mensajes	      OUT	T_IAX_MENSAJES
	)   RETURN NUMBER  IS

    pasexec     NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000);
	  vobjectname VARCHAR2(200):='PAC_MD_DOC_FACTURA .F_VALIDA_FACTURA';
    vpasexec    NUMBER;
    num_err     NUMBER;


  BEGIN

    num_err := PAC_DOC_FACTURA.F_VALIDA_FACTURA(finicio, ffin, vcagente, mensajes);

    IF  num_err != 0 THEN
      RETURN 1;
    END IF;

    RETURN 0;

  EXCEPTION
      WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000005, vpasexec , vparam);

      RETURN NULL;

      WHEN e_object_error THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000006, vpasexec , vparam);

        RETURN NULL;

      WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname ,1000001, vpasexec , vparam, NULL,SQLCODE,SQLERRM);

        RETURN NULL;
  END F_VALIDA_FACTURA;

END  PAC_MD_DOC_FACTURA ;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DOC_FACTURA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DOC_FACTURA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DOC_FACTURA" TO "PROGRAMADORESCSI";
