--------------------------------------------------------
--  DDL for Package PAC_USUARIOS_ADM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_USUARIOS_ADM" 
   AUTHID  CURRENT_USER
IS
  -----------------------------------------------------------------------------
  -- REQUISITOS DE INSTALACION
  -----------------------------------------------------------------------------
	-- 1. CREACION DE ROL sobre ('USTF_GRANT') WITH ADMIN OPTION sobre ('OWN_SCHEMA');
	-- 2. CREACION DE parametros bien adecuados y existentes sobre PARINSTALACION:
	--    f_parinstalacion_t('OWN_SCHEMA');
	--    f_parinstalacion_t('USTF_GRANT');
	--    f_parinstalacion_t('USTF_TSDEF');
	--    f_parinstalacion_t('USTF_TSTMP');
	-- 3. El usuario sobre ('OWN_SCHEMA') debe beneficiarse de los 3 permisos de Sistema:
	-- 	CREATE USER
	-- 	ALTER USER
	-- 	DROP USER
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  -- ACTUACIONES PENDIENTES
  --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  -- Mejora criterio de actualizar GRANTS y SINONIMOS
  -- Crear una meta-tabla para hacer sinonimos privados y publicos, pero que se reutilizable para otros conceptos
  --	Asi permitiria arreglar "f_create_private_syns_special" para "MENSAJE,VENTAS,PAISES"
  -----------------------------------------------------------------------------
  -- Variables y Tipos publicos
  -----------------------------------------------------------------------------
   TYPE    TREG_AUDITAR    IS RECORD
   (  cusuari        VARCHAR2(30)   ,				-- Usuario ejecutor que genera error
      taccion        VARCHAR2(30)   ,				-- Acción emprendida
      tfuncion       VARCHAR2(30)   ,				-- Reconoce de funcion de error
      faccion        DATE           ,				-- Fecha del Error
      err_lcode      CODLITERALES.SLITERA%TYPE,	-- Codigo literal error
      err_lerrm      VARCHAR2(500),-- LITERALES.TLITERA%TYPE (100), TEXTO literal error
      err_sqlcode    NUMBER         ,				-- Codigo de error ORACLE SQLCODE
      err_sqlerrm    VARCHAR2(255)					-- Texto  de error ORACLE SQLERRM
   );                                      		-- AUDITORIAS ERROR
  -----------------------------------------------------------------------------
  -- Declaraciones publicas
  -----------------------------------------------------------------------------
FUNCTION
   f_create_user
   ( ps_username IN VARCHAR2, ps_full_name IN VARCHAR2, pn_cidioma IN VARCHAR2, pn_cdelega IN NUMBER, pn_error OUT CODLITERALES.SLITERA%TYPE )
   RETURN  NUMBER;
FUNCTION
   f_drop_user
   ( ps_username IN VARCHAR2, pn_error OUT CODLITERALES.SLITERA%TYPE )
   RETURN  NUMBER;
FUNCTION
   f_grant_tf
   ( ps_username IN VARCHAR2, ps_owner IN VARCHAR2 )
   RETURN  NUMBER;
FUNCTION
   f_create_see_syns
   ( ps_username IN VARCHAR2, ps_owner IN VARCHAR2 )
   RETURN  NUMBER;
FUNCTION
   f_create_private_syns
   ( ps_username IN VARCHAR2, ps_owner IN VARCHAR2 )
   RETURN  NUMBER;
FUNCTION
   f_create_private_syns_special
   ( ps_username IN VARCHAR2, ps_owner IN VARCHAR2 )
   RETURN  NUMBER;
FUNCTION
   f_tiene_objetos
   ( ps_username IN VARCHAR2 )
   RETURN  BOOLEAN;
FUNCTION
   f_drop_objects
   ( ps_username IN VARCHAR2 )
   RETURN  NUMBER;
  -----------------------------------------------------------------------------
  -- ERRORES
  -----------------------------------------------------------------------------
FUNCTION
   f_clear_error
   RETURN   CODLITERALES.SLITERA%TYPE;
PROCEDURE
   p_set_error
   ( pn_error IN CODLITERALES.SLITERA%TYPE, pn_sqlcode IN NUMBER, ps_sqlerrm IN VARCHAR2, ps_function IN VARCHAR2 );
FUNCTION
   f_get_error
   RETURN   CODLITERALES.SLITERA%TYPE;
PROCEDURE
   dbg_print_errors;
  -----------------------------------------------------------------------------
  -- En un futuro
  -----------------------------------------------------------------------------
-- FUNCTION
--      f_grant_as_user
--      ( ps_username IN VARCHAR2 )
--      RETURN  NUMBER;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
END     pac_usuarios_adm;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_USUARIOS_ADM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_USUARIOS_ADM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_USUARIOS_ADM" TO "PROGRAMADORESCSI";
