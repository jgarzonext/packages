--------------------------------------------------------
--  DDL for Package PAC_CUADRE_CC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CUADRE_CC" authid current_user  IS
---------------------------------------------------------------------------------------------
-- Funcions per la gestió del quadre del compte corrent de la corredoria
---------------------------------------------------------------------------------------------
PROCEDURE proces_batch_quadre(pmodo IN NUMBER, pcempres IN NUMBER, pcidioma IN NUMBER,
	pfcierre IN DATE, pcerror OUT NUMBER, psproces OUT NUMBER, pfproces OUT DATE) ;
---------------------------------------------------------------------------------------------
FUNCTION f_moviments_corredoria (pcempres IN NUMBER, psproces IN NUMBER, pdata_ini IN DATE,
                                 pdata_fi IN DATE, ptext OUT VARCHAR2)  RETURN NUMBER;
---------------------------------------------------------------------------------------------
FUNCTION f_moviments_vida (pcempres IN NUMBER, psproces IN NUMBER, pdata_ini IN DATE,
                           pdata_fi IN DATE, ptext OUT VARCHAR2) RETURN NUMBER;
---------------------------------------------------------------------------------------------
FUNCTION f_completa_dades(pcempres IN NUMBER, psproces IN NUMBER,
                           pdata_fi IN DATE, ptext OUT VARCHAR2) RETURN NUMBER ;
---------------------------------------------------------------------------------------------
FUNCTION f_sinistres (pcempres IN NUMBER, pdata_ini IN DATE, pdata_fi IN DATE,
                      psproces IN NUMBER, ptext OUT VARCHAR2) RETURN NUMBER;
---------------------------------------------------------------------------------------------
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CUADRE_CC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CUADRE_CC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CUADRE_CC" TO "PROGRAMADORESCSI";
