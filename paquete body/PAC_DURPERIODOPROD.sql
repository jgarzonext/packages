--------------------------------------------------------
--  DDL for Package Body PAC_DURPERIODOPROD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_DURPERIODOPROD" 
AS
   ------------------------------------------------------------------------------------------
   -- contar registres ----------------------------------------------------------------------
   ------------------------------------------------------------------------------------------
   ----
  FUNCTION f_contar_registros (psproduc IN NUMBER, pfinicio IN DATE, pndurper IN NUMBER)RETURN NUMBER IS
     num number(6);
  BEGIN
     select count(*)
	 into num
	 from durperiodoprod
	 where
	 sproduc = psproduc and
	 finicio = pfinicio	and
	 ndurper = pndurper;
	 RETURN(num);
  END;
  ---------------------------------------------------------------------------------------------
  -- darrera data -----------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------

  FUNCTION f_ultima_data (pfecha IN DATE, psproduc IN NUMBER) RETURN NUMBER IS
     data_darrera date;
  BEGIN
     select max(finicio)
     into data_darrera
     from durperiodoprod
	 where sproduc = psproduc;

	 If data_darrera = pfecha then
        RETURN(0);
     else
        RETURN(1);
	 end if;

  END f_ultima_data;

   ------------------------------------------------------------------------------------------
   -- insersió de registres en la taula durperiodoprod----------------------------------------
   -------------------------------------------------------------------------------------------
   FUNCTION f_insert_durperiodoprod( psproduc IN NUMBER, pfinicio IN DATE, pndurper IN NUMBER) RETURN NUMBER IS

   BEGIN

	  INSERT INTO durperiodoprod (sproduc, finicio, ndurper)
      values(psproduc, pfinicio, pndurper);

	  RETURN(0);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
	     p_tab_error (F_SYSDATE,F_USER, 'PAC_DURPERIODOPROD.f_insert_durperiodoprod' , NULL,
         'Error de índice duplicado al insertar el registro en la tabla durperiodoprod', SQLERRM);
         RETURN(SQLERRM);
	  WHEN OTHERS THEN
	     p_tab_error (F_SYSDATE,F_USER, 'PAC_DURPERIODOPROD.f_insert_durperiodoprod' , NULL,
         'Error no controlado al insertar el registro en la tabla durperiodoprod', SQLERRM);
		 RETURN(SQLERRM);

   END f_insert_durperiodoprod;

   -----------------------------------------------------------------------------------
   -- modificació de registres en la taula durperiodoprod ----------------------------
   -----------------------------------------------------------------------------------

   FUNCTION f_modificacio_durperiodoprod( psproduc IN NUMBER, pfinicio IN DATE, pndurper IN NUMBER, old_pndurper IN NUMBER)RETURN NUMBER IS

   BEGIN
   	  UPDATE  durperiodoprod
	    set ndurper = pndurper
		WHERE sproduc = psproduc AND
		finicio = pfinicio AND
		ndurper = old_pndurper;

	  RETURN(0);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
	     p_tab_error (F_SYSDATE,F_USER, 'PAC_DURPERIODOPROD.f_modificacio_durperiodoprod' , NULL,
         'Error de índice duplicado al modificar el registro en la tabla durperiodoprod', SQLERRM);
         RETURN(SQLERRM);
	  WHEN OTHERS THEN
	     p_tab_error (F_SYSDATE,F_USER, 'PAC_DURPERIODOPROD.f_modificacio_durperiodoprod' , NULL,
         'Error no controlado al modificar el registro en la tabla durperiodoprod', SQLERRM);
		 RETURN(SQLERRM);
 END f_modificacio_durperiodoprod;

  -----------------------------------------------------------------------------------
   --borrar registro en la taula durperiodoprod ----------------------------
   -----------------------------------------------------------------------------------

 FUNCTION f_borrar_durperiodoprod( psproduc IN NUMBER, pfinicio IN DATE, pndurper IN NUMBER) RETURN NUMBER IS

 BEGIN
    delete from durperiodoprod
    WHERE sproduc = psproduc AND
		finicio = pfinicio AND
		ndurper = pndurper;

	RETURN(0);

  EXCEPTION
    WHEN OTHERS THEN
	     p_tab_error (F_SYSDATE,F_USER, 'PAC_DURPERIODOPROD.f_borrar_durperiodoprod' , NULL,
         'Error no controlado al borrar el registro en la tabla durperiodoprod', SQLERRM);
		 RETURN(SQLERRM);
 END f_borrar_durperiodoprod;



 FUNCTION f_fecha_inicio_periodo_vigente( psproduc IN NUMBER, p_fecha_inicio_max  OUT DATE) RETURN NUMBER IS
     fecha_maxima date;
  BEGIN
     select max(finicio)
     into fecha_maxima
     from durperiodoprod
	 where sproduc = psproduc;

	 p_fecha_inicio_max := fecha_maxima;
	 RETURN (0);

  EXCEPTION
    WHEN OTHERS THEN
         p_tab_error (F_SYSDATE,F_USER, 'PAC_DURPERIODOPROD.f_fecha_inicio_periodo_vigente' , NULL,
         'Error no controlado al buscar la fecha inicio del período vigente', SQLERRM);
	     RETURN(SQLERRM);
 END f_fecha_inicio_periodo_vigente;


 FUNCTION f_actualiza_fecha_fin (psproduc IN NUMBER, p_fecha_fin IN DATE) RETURN NUMBER IS

  BEGIN

   	  UPDATE  durperiodoprod
	    SET ffin = p_fecha_fin
		WHERE sproduc = psproduc
		  AND ffin is null;

	  RETURN (0);

  EXCEPTION
    WHEN OTHERS THEN
         p_tab_error (F_SYSDATE,F_USER, 'PAC_DURPERIODOPROD.f_actualiza_fecha_fin' , NULL,
         'Error no controlado al actualizar la fecha fin del período vigente', SQLERRM);
	     RETURN(SQLERRM);
 END f_actualiza_fecha_fin;


 FUNCTION f_abrir_periodo_anterior (psproduc IN NUMBER, p_fecha_inicio IN DATE) RETURN NUMBER IS

    num  NUMBER;
  BEGIN

    -- Se mira si no queda ningun registro con fecha fin a null, lo que quiere decir que se han
	-- borrado todos los registros de un periodo. Si es así, se debe abrir el periodo anterior
	-- si es que hay, es decir, si no se ha borrado el único período que existia

	num := 0;

	Select count(*)
	into num
	from durperiodoprod
	where sproduc = psproduc
	  and ffin is null;

	-- Si hay registros con ffin = null (num <> 0) no se debe abrir el periodo anterior
	-- pues aun existen más registros del periodo vigente

	IF num = 0 THEN  -- se han borrado todos los registros de un periodo,
	                 --por lo que se debe abrir el periodo anterior, si hay

	    -- Se mira si existen registros con fecha fin igual a la fecha de inicio del periodo que se
		-- acaba de eliminar (es para controlar que no se está eliminando el último registro, si fuera
		-- el caso de que sólo quedaba 1)

		 num := 0;

		 select count(*)
		 into num
		 from durperiodoprod
		 where sproduc = psproduc
		   and ffin = p_fecha_inicio;


	     IF num <> 0 THEN -- existen registros, por lo que se actualiza su fecha fin (se abre el periodo)

	        UPDATE durperiodoprod
			SET ffin = null
		    WHERE sproduc = psproduc
		      AND ffin = p_fecha_inicio;

		 END IF;

     END IF;

	 RETURN (0);

  EXCEPTION
    WHEN OTHERS THEN
         p_tab_error (F_SYSDATE,F_USER, 'PAC_DURPERIODOPROD.f_abrir_periodo_anterior' , NULL,
         'Error no controlado al abrir el periodo anterior', SQLERRM);
	     RETURN(SQLERRM);
 END f_abrir_periodo_anterior;

END PAC_DURPERIODOPROD;

/

  GRANT EXECUTE ON "AXIS"."PAC_DURPERIODOPROD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DURPERIODOPROD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DURPERIODOPROD" TO "PROGRAMADORESCSI";
