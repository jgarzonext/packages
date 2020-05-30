--------------------------------------------------------
--  DDL for Package PAC_GASTOS_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_GASTOS_ULK" AUTHID CURRENT_USER
IS
  -- Variable necesaria para
  x NUMBER := 0;

  TYPE cur_detgastos_hisseg IS REF CURSOR;

  ----------------------------------------------------------------------------------------------------------------
  --- RSC 03-07-2007 Pasamosa gasto por defecto NO a todos los gastos diferentes del tipo pasado por parametro ---
  ----------------------------------------------------------------------------------------------------------------
  FUNCTION FF_MOD_CDEFECT_DETGASTOS_ULK (p_cgasto DETGASTOS_ULK.CGASTO%TYPE,p_ctipo DETGASTOS_ULK.CTIPO%TYPE) return NUMBER;  

  ----------------------------------------------------------------------------------------------------------------
  --- RSC 03-07-2007 Obtencion del numero de gastos vigentes, diferentes a p_cgasto con cdefect igual a 1     ----
  ----------------------------------------------------------------------------------------------------------------
  FUNCTION FF_NUM_DEFECT_DETGASTOS_ULK (p_cgasto DETGASTOS_ULK.CGASTO%TYPE,p_ctipo DETGASTOS_ULK.CTIPO%TYPE) return NUMBER;

  -----------------------------------------------------------------------------------------
  --- RSC 03-07-2007 Gestion alta de mantenimiento de gastos de  productos Unit Linked ----
  -----------------------------------------------------------------------------------------
  PROCEDURE P_MANTENIMIENTO_DETGASTOS_ULK (rt_detgastos_ulk IN DETGASTOS_ULK%ROWTYPE,
                                 rt_newdetgastos_ulk IN DETGASTOS_ULK%ROWTYPE);
 
  ---------------------------------------------------------------------------------------------------------
  --- RSC 27-07-2007 Borra el registro de DETGASTOS_ULK pasado por parametro (solo si és el vigente). 
  --- Instaura el anterior como vigente. Hace un tratamiento para si es defecto o no.
  ---------------------------------------------------------------------------------------------------------                     
  FUNCTION FF_DEL_DETGASTOS_ULK (p_cgasto DETGASTOS_ULK.CGASTO%TYPE,p_finivig DETGASTOS_ULK.FINIVIG%TYPE,p_ctipo DETGASTOS_ULK.CTIPO%TYPE,p_ffinvig DETGASTOS_ULK.FINIVIG%TYPE) return NUMBER;
  
  ---------------------------------------------------------------------------------------------------------
  --- RSC 18-09-2007 Metodo privado del paquete utilizado por las funciones ff_detgastos_gestion_hisseg y
  --  ff_detgastos_redis_hisseg
  ---------------------------------------------------------------------------------------------------------
  FUNCTION f_particion_hisseg (v1 IN NUMBER, v2 IN NUMBER) RETURN NUMBER;
  
  ---------------------------------------------------------------------------------------------------------
  --- RSC 18-09-2007 Fusión, intercalamiento de fechas entre las tablas historicoseguros y detgastos_ulk.
  -- HISTORICOSEGUROS nos da un rango de fechas en el cual un seguro tenia un tipo de gasto de gestión, pero
  -- en este rango a nivel general pueden haber variaciones del gasto en cuestión. Por esto se debe intercalar
  -- los valores de DETGASOTS_ULK con los de HISTORICOSEGUROS.  
  ---------------------------------------------------------------------------------------------------------
  FUNCTION ff_detgastos_gestion_hisseg (psseguro IN NUMBER) RETURN cur_detgastos_hisseg;
  
  ---------------------------------------------------------------------------------------------------------
  --- RSC 18-09-2007 Fusión, intercalamiento de fechas entre las tablas historicoseguros y detgastos_ulk.
  -- Idem que ff_detgastos_gestion_hisseg.  
  ---------------------------------------------------------------------------------------------------------
  FUNCTION ff_detgastos_redis_hisseg (psseguro IN NUMBER) RETURN cur_detgastos_hisseg;
  
  --FUNCTION ff_get_range_detgastos (pFMOVIMI_FINAL IN DATE, pFMOVIMI_INICIAL IN DATE, pCGASTO IN NUMBER, rt_detgastos_ulk IN OUT DETGASTOS_ULK%ROWTYPE) RETURN NUMBER;
END PAC_GASTOS_ULK; 
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_ULK" TO "PROGRAMADORESCSI";
