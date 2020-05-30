--------------------------------------------------------
--  DDL for Package PAC_MD_DOC_FACTURA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_DOC_FACTURA" AS


/******************************************************************************
   NOMBRE:      PAC_MD_DOC_FACTURA
   PROP¿¿¿¿¿SITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿¿¿¿n
   ---------  ----------  ---------------  ------------------------------------
    1.0        02/10/2015   FFO                1. CREACION
******************************************************************************/
   e_object_error EXCEPTION;


   e_param_error  EXCEPTION;




	FUNCTION  F_GET_FACTURA(
			 pusuario	    IN	VARCHAR2,
			 mensajes	OUT	T_IAX_MENSAJES
	)   RETURN SYS_REFCURSOR;

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
	)   RETURN NUMBER;

  FUNCTION   F_ANULA_FACTURA(
			  pdocfactura	    IN NUMBER,
        pnsinies	      IN NUMBER,
			  mensajes	      OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;


  FUNCTION   F_VALIDA_FACTURA(
			  finicio	        IN DATE,
        ffin    	      IN DATE,
        vcagente        IN NUMBER,
			  mensajes	      OUT	T_IAX_MENSAJES
	)   RETURN NUMBER;

END  PAC_MD_DOC_FACTURA  ;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DOC_FACTURA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DOC_FACTURA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DOC_FACTURA" TO "PROGRAMADORESCSI";
