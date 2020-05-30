--------------------------------------------------------
--  DDL for Package PAC_GASTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_GASTOS" AUTHID CURRENT_USER
IS
------------------------------------------------------------------------------------------------------
---creado XCG 08-01-2007 Cálculo y gestión del porcentaje de gastos del producto------------------
------------------------------------------------------------------------------------------------------
  FUNCTION f_contar_registros (psproduc IN NUMBER) RETURN NUMBER;

  FUNCTION f_insert_gastos( psproduc IN NUMBER, pfecha IN DATE, ppgastos IN NUMBER, pctipapl IN NUMBER) RETURN NUMBER;

  FUNCTION f_modificar_gastos (psproduc IN NUMBER, pfecha IN DATE, ppgastos IN NUMBER, pctipapl IN NUMBER) RETURN NUMBER;

  FUNCTION f_borrar_gastos (psproduc IN NUMBER, pfecha IN DATE, ppgastos IN NUMBER, pctipapl IN NUMBER) RETURN NUMBER;

  FUNCTION f_buscar_nomaplica (pcvalor IN NUMBER, pcatribu IN NUMBER, pcidioma IN NUMBER, pnomaplica IN OUT VARCHAR2) RETURN NUMBER;

  FUNCTION Ff_gastos_producto (psproduc IN NUMBER, pfecha IN DATE) RETURN NUMBER;

  FUNCTION Ff_gastos_seguro (ptablas IN VARCHAR2, psseguro IN NUMBER, pfecha  IN DATE DEFAULT F_SYSDATE)RETURN NUMBER;

  FUNCTION f_abrir_periodo_anterior (psproduc IN NUMBER, pfecha IN DATE) RETURN NUMBER;

END PAC_GASTOS;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_GASTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS" TO "PROGRAMADORESCSI";
