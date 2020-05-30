--------------------------------------------------------
--  DDL for Package PAC_DURPERIODOPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DURPERIODOPROD" AUTHID CURRENT_USER
IS
---------------------------------------------------------------------------------------------------------------
---creado XCG 18-01-2007 Cálculo y gestión de las duraciones de periodo garantizado permitidas en producto ----
---------------------------------------------------------------------------------------------------------------
  FUNCTION f_contar_registros (psproduc IN NUMBER, pfinicio IN DATE, pndurper IN NUMBER)RETURN NUMBER;
  FUNCTION f_ultima_data (pfecha IN DATE, psproduc IN NUMBER) RETURN NUMBER;
  FUNCTION f_insert_durperiodoprod( psproduc IN NUMBER, pfinicio IN DATE, pndurper IN NUMBER)RETURN NUMBER;
  FUNCTION f_modificacio_durperiodoprod( psproduc IN NUMBER, pfinicio IN DATE, pndurper IN NUMBER, old_pndurper IN NUMBER)RETURN NUMBER;
  FUNCTION f_borrar_durperiodoprod( psproduc IN NUMBER, pfinicio IN DATE, pndurper IN NUMBER)RETURN NUMBER;
  FUNCTION f_fecha_inicio_periodo_vigente( psproduc IN NUMBER, p_fecha_inicio_max OUT DATE) RETURN NUMBER;
  FUNCTION f_actualiza_fecha_fin (psproduc IN NUMBER, p_fecha_fin IN DATE) RETURN NUMBER;
  FUNCTION f_abrir_periodo_anterior (psproduc IN NUMBER, p_fecha_inicio IN DATE) RETURN NUMBER;

END PAC_DURPERIODOPROD;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_DURPERIODOPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DURPERIODOPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DURPERIODOPROD" TO "PROGRAMADORESCSI";
