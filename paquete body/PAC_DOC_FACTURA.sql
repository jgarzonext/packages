--------------------------------------------------------
--  DDL for Package Body PAC_DOC_FACTURA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_DOC_FACTURA" AS

/******************************************************************************
   NOMBRE:      PAC_DOC_FACTURA
   PROP¿SITO: Nuevo package con las funciones que se utilizan en las impresiones.
   En este package principalmente se utilizar¿ para funciones de validaci¿n de si un documento se imprime o no.

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
    1.0        18/03/2015   FFO                1. CREACION
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

	FUNCTION  F_GET_FACTURA(
			 pusuario	    IN	VARCHAR2,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR
  IS
    pasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000);
	  vobjectname VARCHAR2(200):='PAC_DOC_FACTURA.F_DOC_FACTURA';

    vsquery     VARCHAR2(5000);
	  cur         SYS_REFCURSOR;
    vpasexec    NUMBER;

    CURSOR c_doc_factura IS
        SELECT  DOC_FACTURA,
                NSINIES,
                NDOCUMENTO,
                DESCRIPCION,
                FRECLAMACION,
                FRECEPCION,
                IDDOC_IMP,
                EANULACION,
                CUSUALT,
                FALTA,
                CUSUMOD,
                FMODIF FROM DOC_FACTURA;

  BEGIN

     vpasexec:=1;
	    vsquery := 'SELECT  DOC_FACTURA,
                NSINIES,
                NDOCUMENTO,
                DESCRIPCION,
                FRECLAMACION,
                FRECEPCION,
                IDDOC_IMP,
                EANULACION,
                CUSUALT,
                FALTA,
                CUSUMOD,
                FMODIF FROM DOC_FACTURA';
    cur:=pac_md_listvalores.f_opencursor(vsquery, mensajes);
    RETURN cur;
  EXCEPTION
      WHEN OTHERS THEN
               pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);

	             IF cur%isopen THEN
	               CLOSE cur;
	             END IF;

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
	  vobjectname VARCHAR2(200):='PAC_DOC_FACTURA.F_SET_FACTURA';
    vpasexec    NUMBER;


    CURSOR c_doc_factura IS
        SELECT 1 FROM DOC_FACTURA
          WHERE  DOC_FACTURA = pdocfactura
           AND   NSINIES = pnsinies;

  BEGIN

    INSERT INTO DOC_FACTURA
    (
      DOC_FACTURA,
      NSINIES,
      NDOCUMENTO,
      DESCRIPCION,
      FRECLAMACION,
      FRECEPCION,
      IDDOC_IMP,
      EANULACION,
      CUSUALT,
      FALTA
    )
    VALUES
    (
      pdocfactura,
      pnsinies,
      pndocumento,
      pdescripcion,
      pfreclamacion,
      pfrecepcion,
      piddoc_imp,
      peanulacion,
      pcusualt,
      F_SYSDATE
    );

    RETURN 0;
  EXCEPTION
      WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
	             RETURN 1;
  END F_SET_FACTURA;


  FUNCTION   F_ANULA_FACTURA(
			  pdocfactura	    IN NUMBER,
        pnsinies	      IN NUMBER,
			  mensajes	      OUT	T_IAX_MENSAJES
	)   RETURN NUMBER IS


    pasexec    NUMBER;
	  vnumerr     NUMBER;
	  vparam      VARCHAR2(1000);
	  vobjectname VARCHAR2(200):='PAC_DOC_FACTURA.F_ANULA_FACTURA';
    vpasexec    NUMBER;
  BEGIN

      UPDATE DOC_FACTURA SET
        EANULACION = 1
      WHERE DOC_FACTURA = pdocfactura
       AND  NSINIES = pnsinies;

      RETURN 0;
  EXCEPTION
      WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
	             RETURN 1;
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
	  vobjectname VARCHAR2(200):='PAC_DOC_FACTURA.F_VALIDA_FACTURA';
    vpasexec    NUMBER;
    vpagos      NUMBER := 0;

    CURSOR c_sin_tramita_pago IS
      SELECT SIDEPAG, NSINIES FROM sin_tramita_pago
        WHERE cestado = 4
          AND cagente = vcagente
          AND fordpag BETWEEN finicio AND ffin;

  BEGIN

    FOR var IN c_sin_tramita_pago LOOP
        vpagos := vpagos + 1;
    END LOOP;

    IF vpagos != 0 THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  EXCEPTION
      WHEN OTHERS THEN
        pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam, NULL, SQLCODE, SQLERRM);
	             RETURN 1;
  END F_VALIDA_FACTURA;






END  PAC_DOC_FACTURA;

/

  GRANT EXECUTE ON "AXIS"."PAC_DOC_FACTURA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DOC_FACTURA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DOC_FACTURA" TO "PROGRAMADORESCSI";
