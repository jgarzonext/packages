--------------------------------------------------------
--  DDL for Package PAC_ISQLFOR_REPORT_CONF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ISQLFOR_REPORT_CONF" AS


/******************************************************************************
   NOMBRE:      pac_isqlfor_report__conf
   PROP真SITO: Nuevo package con las funciones que se utilizan en las impresiones de reportes.
   En este package principalmente se utilizar真 para funciones de validaci真n de si un documento se imprime o no.

   REVISIONES:
   Ver        Fecha        Autor             Descripci真n
   ---------  ----------  ---------------  ------------------------------------
    1.0        18/03/2015   FFO                1. CREACION
******************************************************************************/
   e_object_error EXCEPTION;


   e_param_error  EXCEPTION;




	FUNCTION f_factu_intermedi (
			 pcagente	IN	NUMBER,
			 pcempres	IN	NUMBER,
			 pffecmov	IN	DATE,
			 ptipo	IN	NUMBER
	)   RETURN VARCHAR2;


  FUNCTION f_jrep_trad(
  pentrada IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_intermediarios(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcolumn IN NUMBER,
      pmodo IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2 ;

/******************************************************************************
   NOMBRE:      f_numero_persona_rel
   PROP真SITO:odtener datos de personas relacionadas que sean socios consorcio


   pdato: dato a odtener
        1 nombre
        2 nit

   REVISIONES:
   Ver        Fecha        Autor             Descripci真n
   ---------  ----------  ---------------  ------------------------------------
    1.0        01/02/2017   FFO                1. CREACION
******************************************************************************/
  FUNCTION f_numero_persona_rel (
    pdato   	IN    NUMBER,
    vsperson  IN    NUMBER,
    vnumero  IN    NUMBER DEFAULT 1
	)  RETURN VARCHAR2;

END pac_isqlfor_report_conf;

/

  GRANT EXECUTE ON "AXIS"."PAC_ISQLFOR_REPORT_CONF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ISQLFOR_REPORT_CONF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ISQLFOR_REPORT_CONF" TO "PROGRAMADORESCSI";
