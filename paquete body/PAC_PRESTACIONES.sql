--------------------------------------------------------
--  DDL for Package Body PAC_PRESTACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PRESTACIONES" 
IS
   FUNCTION f_validar_poliza (pmodo IN NUMBER, psseguro IN NUMBER, pnpoliza IN NUMBER,
                                                             pncertif IN NUMBER)  RETURN NUMBER
   IS
   /**********************************************************************************************************************
      3-7-2006. YIL
	  F_validar_poliza: función que realizará las validaciones necesarias para saber si se puede abrir un parte
	                                   de prestatación a una póliza determinada

				pmodo: 1 validaciones en DEPARTAMENTO
				                 2 validaciones en TF
				psseguro: identificador de la póliza a validar
				pnpoliza: número de póliza a validar
				ncertif: número de certificado de la póliza
************************************************************************************************************************/
   v_sseguro			NUMBER;
   v_csituac 			  NUMBER;
   v_cagrpro			  NUMBER;
   v_sproduc			  NUMBER;
   num_err				  NUMBER;
   cuantos_c			  NUMBER;
   cuantos				  NUMBER;
   BEGIN
      IF pnpoliza IS NOT NULL THEN
	     IF pncertif IS NULL THEN
		    RETURN 101901; -- paso incorrecto de parámetros a la función
		 END IF;

		 BEGIN
		    SELECT  sseguro, csituac, cagrpro, sproduc
			    INTO v_sseguro, v_csituac, v_cagrpro, v_sproduc
		    FROM seguros
		    WHERE npoliza = pnpoliza AND ncertif = pncertif;
		 EXCEPTION
		    WHEN OTHERS THEN
			   RETURN 101903; -- seguro no encontrado en la tabla seguros
		 END;

	  ELSE
	     BEGIN
		    SELECT  sseguro, csituac, cagrpro, sproduc
			 INTO v_sseguro, v_csituac, v_cagrpro, v_sproduc
		    FROM seguros
		    WHERE sseguro = psseguro;
		 EXCEPTION
		    WHEN OTHERS THEN
			   RETURN 101903; -- seguro no encontrado en la tabla seguros
		 END;
      END IF;

     -- Validar que la póliza admita prestaciones
	  IF v_cagrpro NOT IN (2, 11) THEN-- no ahorro ni Planes
	     RETURN 102411; -- esta póliza no es un producto de ahorro
	  ELSE
	     -- Validar el estado de la póliza. Sólo admitir pólizas vigentes
		 num_err := f_vigente(psseguro, NULL , f_sysdate);
		 IF num_err <> 0 THEN
		    IF v_csituac = 1 THEN
			   num_err := 101480; -- la póliza está suspendida
			ELSIF v_csituac IN (2,3) THEN
			   num_err := 101483; -- la póliza está anulada
			ELSIF v_csituac = 4 THEN
			   num_err := 101666;  -- la póliza es una propuesta de Alta
			END IF;
		 ELSIF num_err = 0 AND v_csituac = 5 THEN
		    num_err := 101481; -- la póliza tiene una propuesta de suplemento
		 END IF;
		 IF num_err <> 0 THEN
		    RETURN num_err;
		 END IF;

      END IF;

	  IF pmodo = 2 THEN --TF2
	     -- miramos que el plan esté abierto
		 IF  f_ppabierto(psseguro, NULL, f_sysdate) <> 'A' THEN
		    RETURN 152766; -- plan no activo en el día de hoy
		END IF;

		-- miramos que el plan no sea de empleo
		IF NVL(f_parproductos_v(v_sproduc,'PPEMPLEO'),0) = 1 THEN
		   RETURN 152792; --operación no válida para planes de empelo
		END IF;

		-- miramos si tiene prestaciones inactivas
		SELECT COUNT(*) INTO CUANTOS
        FROM PRESTAPLAN
        WHERE sseguro = psseguro
        AND cestado = 1;  -- inactivo

        IF CUANTOS > 0 THEN
		   RETURN 109432; -- El contrato ya tiene prestaciones en ejecución.
        END IF;


	  END IF;
	  IF pmodo = 1 THEN -- Departamento
	        -- Controlamos que todos los movimientos de ctaseguro están informados con el valor liquidativo
		  SELECT COUNT(*) INTO cuantos_c
		  FROM ctaseguro
		  WHERE sseguro = psseguro
		  AND nparpla IS NULL
		  AND cmovimi NOT IN (0);

		  IF cuantos_c > 0 THEN
		     RETURN 109364;   -- la póliza tiene movimientos sin valor liquidativo
	      END IF;

		   -- Departamento. No debe tener recibos pendientes.
		   IF F_recpen_pp(psseguro, 1) > 0 THEN
		      RETURN 111388;  -- ATENCION: esta póliza tiene recibos pendientes
		   END IF;
	  END IF;

	  RETURN 0;

   EXCEPTION
      WHEN OTHERS THEN
	     p_tab_error (f_sysdate,F_USER,  'PAC_PRESTACIONES.F_VALIDAR_POLIZA',
                      NULL, 'error no controlat sseguro ='||psseguro,  SQLERRM  );
   END f_validar_poliza;

   FUNCTION f_parte_abierto(psseguro IN NUMBER, psprestaplan OUT NUMBER, psperson OUT NUMBER)
   RETURN NUMBER IS
   /****************************************************************************************************************
      Funció que devuelve el parte abierto de una póliza y el causante de este parte
	  **************************************************************************************************************/

   BEGIN
      -- devolvemos el parte abierto en estado = 2 en proceso
	  SELECT SPRESTAPLAN, SPERSON
	  INTO psprestaplan, psperson
	  FROM prestaplan
	  WHERE sseguro = psseguro
	  AND cestado = 2;

	  RETURN 0;

   EXCEPTION
      WHEN OTHERS THEN
	     p_tab_error (f_sysdate,F_USER,  'PAC_PRESTACIONES.F_parte_abierto',
                      NULL, 'error no controlat sseguro ='||psseguro,  SQLERRM  );
			RETURN 0;
   END f_parte_abierto;

   FUNCTION f_causante_prestacion(pmodo IN NUMBER, psseguro IN NUMBER, psperson OUT NUMBER)
        RETURN NUMBER IS
   /**************************************************************************************************************************
      -- pmodo 1: Mira si el causante del parte puede ser el parícipe.
	                         Si es así, devuelve el sperson del partícipe, sino devuelve NULL
	  -- pmodo 2: mira el causante del parte abierto

  *****************************************************************************************************************************/
      cuantos				NUMBER;
	  traza					NUMBER;
   BEGIN
      IF pmodo = 1 THEN
	     traza := 1;
         -- Miramos si todavía es el partícipe. Si hay una prestación con muerte es que como mínimo el
	     -- partícipe ha fallecido
         SELECT COUNT(*) INTO cuantos
	     FROM PRESTAPLAN
	     WHERE sseguro = psseguro
	     AND CTIPREN = 3; -- fallecimiento

	     IF CUANTOS > 0 THEN
	        RETURN 0;  -- psperson = NULL
	     END IF;

	     SELECT sperson
	     INTO psperson
	     FROM riesgos
	     WHERE sseguro = psseguro;
	  END IF;

	  IF pmodo = 2 THEN
	     traza := 2;
	     SELECT sperson
		 INTO psperson
		 FROM prestaplan
		 WHERE sseguro = psseguro
		 AND cestado = 2;
	  END IF;
	  RETURN 0;

	EXCEPTION
      WHEN OTHERS THEN
	     p_tab_error (f_sysdate,F_USER,  'PAC_PRESTACIONES.F_causante_prestacion',
                      traza, 'error no controlat sseguro ='||psseguro,  SQLERRM  );
	     RETURN 0;
   END f_causante_prestacion;

   FUNCTION f_validar_causante_prestacion(psseguro IN NUMBER, psperson IN NUMBER
                            ) RETURN NUMBER IS
   /************************************************************************************************************************
      f_validar_causante_prestacion: valida el causante
   ************************************************************************************************************************/
      cuantos     NUMBER;
   BEGIN
      -- Valida que no tenga partes abiertos en estado inactivo
      SELECT COUNT(*) INTO cuantos
	  FROM PRESTAPLAN
	  WHERE sseguro = psseguro
	  AND sperson = psperson
	  AND cestado = 1; -- inactivo

	  IF cuantos > 0 THEN
	     RETURN 109461; -- existe una prestación de esta persona abierta de un nivel inferior
	  END IF;


	  RETURN 0;

   END f_validar_causante_prestacion;

   FUNCTION f_nivel(psseguro IN NUMBER, psperson IN NUMBER, pnnivel OUT NUMBER
                            ) RETURN NUMBER IS
   /************************************************************************************************************************
      f_validar_causante_prestacion:  devuelve el nivel del nuevo parte de prestación
	                                               que le correspondería
   ************************************************************************************************************************/

   BEGIN

      SELECT NVL(MAX(NVL(NNIVEL,0)),0) + 1
	  INTO pnnivel
	  FROM PRESTAPLAN
	  WHERE sseguro = psseguro
	  AND sperson = psperson
	  AND cestado= 2;

	  RETURN 0;

   END f_nivel;


   FUNCTION f_validar_fecha(pmodo IN NUMBER, psseguro IN NUMBER,  psperson IN NUMBER,
                           pfaccion IN DATE) RETURN NUMBER IS
   /*****************************************************************************************************************
      F_validar_fecha: función que realizará las validaciones necesarias de la fecha de ocurrencia de
	                 la contingencia

				pmodo: 1 validaciones en DEPARTAMENTO
				                2  validaciones en TF
				psseguro: identificador de la póliza a validar
				psperson: identificador de la persona causante del parte
				pfaccion: fecha de ocurrencia

   ********************************************************************************************************************/
   reg_seg						  seguros%ROWTYPE;
   cuantos						  NUMBER;
   v_fantigi					  DATE;
   v_maxfaccion					  DATE;
   err							  NUMBER;
   traza						  NUMBER;
   BEGIN

   IF pmodo IN (1,2) THEN --validaciones generales en los dos entornos
      traza := 1;
      -- la fecha de ocurrencia debe ser mayor a la fecha de efecto de la póliza o a la fecha de traspaso
         SELECT *
	     INTO reg_seg
         FROM seguros
	     WHERE sseguro = psseguro;

	     SELECT MIN(fantigi) INTO v_fantigi
	     FROM trasplainout
	     WHERE sseguro = psseguro
	     AND ctiptras = 1
	     AND cestado = 4
	     AND fantigi IS NOT NULL;

	     IF (pfaccion < reg_seg.fefecto) OR (pfaccion < v_fantigi) THEN
	        RETURN 109754;  -- la fecha de contingencia no puede ser menor a la fecha de efecto
         END IF;
   /***********************************/
         traza := 2;
         -- Verificamos que todos los ptraspasos que ha realizado tienen la fecha de antiguedad del plan asignada
	     SELECT COUNT(*)  INTO cuantos
	     FROM trasplainout
	     WHERE sseguro = psseguro
	     AND fantigi IS NULL;

	     IF cuantos > 0 THEN
	        RETURN 111330;  -- atención: existen traspasos realizados sin fecha de antigüedad
	     END IF;
   /**********************************/
         traza := 3;
          -- La fecha de ocurrencia debe ser mayor  la fecha de los niveles inferiores
		  SELECT MAX(faccion) INTO v_maxfaccion
		  FROM prestaplan p, benefprestaplan b
		  WHERE p.sseguro =  psseguro
		  AND p.sprestaplan = b.sprestaplan
		  AND b.sperson = psperson;

		  IF pfaccion <= v_maxfaccion THEN
		     RETURN 109467;  --la fecha nopuede ser inferior a la de la anterior prestación
		   END IF;
	   END IF;
       IF pmodo = 1 THEN -- en Departamento
	      traza := 4;
	      -- Validamos que no tiene excesos pendientes
		  err := Pac_Tfv.f_calcula_importe_anual(psseguro, TO_CHAR(f_sysdate,'yyyy'), psperson);
		  IF err = -1 THEN -- ha superado el límite
		     RETURN 109747; -- antes tiene que retornar las aportaciones excedidas de este año
		  END IF;
		END IF;
	EXCEPTION
      WHEN OTHERS THEN
	     p_tab_error (f_sysdate,F_USER,  'PAC_PRESTACIONES.F_validar_fecha',
                      traza, 'error no controlat sseguro ='||psseguro,  SQLERRM  );
	     RETURN 0;

   END f_validar_fecha;

   FUNCTION f_calcula_participaciones(psseguro IN NUMBER, psperson IN NUMBER, pctipren IN NUMBER,
                                  pnivel IN NUMBER, pfaccion IN DATE, pctipjub IN NUMBER ,
								  pnparti_actual OUT NUMBER, pnparti_pos OUT NUMBER,
								  piparti_actual OUT NUMBER, piparti_pos OUT NUMBER) RETURN NUMBER IS
   /*************************************************************************************************************************
        f_calcula_participaciones: calculará las participaciones a asignar en el parte según el nivel y
		                el motivo

			psseguro: identificador de la póliza
			psperson: identificador del causante del parte
			pnivel: nivel del parte
			pfaccion: fecha de ocurrencia
			pctipren: motivo de la contingencia 1.- Juilación 2.- Invalidez 3.- Muerte 4.- Desempleo 5.- Enfermedad Grave
			pctipjub: tipo de invalidez 1.- Total 2.- Parcial

			pnparti_actual: número de participaciones a fecha de ocurrencia
			pnparti_pos: número de participaciones posteriores a la fecha de ocurrencia
      ***********************************************************************************************************************/
	  presta_actual					NUMBER:= 0;
	  presta_posterior			 NUMBER:= 0;
	  pnparti					 NUMBER;
	  divisa					 NUMBER := 1;
	  v_fvalora					 DATE;
	  valor_parti				 NUMBER;
	  traza						 NUMBER;
   BEGIN
      IF pctipren = 2 AND pctipjub IS NULL THEN
	     RETURN 101901; -- paso incorrecto de parámetros a la función
	  END IF;

	  IF pnivel = 1 THEN
	  traza := 1;
	        pnparti_actual := Pac_Tfv.f_saldo_presta_actual(psseguro, pfaccion +1, 0);
			pnparti_pos := Pac_Tfv.f_saldo_presta_posterior(psseguro, pfaccion +1, 0);
			--pnparti := NVL(presta_actual,0) + NVL(presta_posterior,0);
	  ELSE
	  traza := 2;
	     -- buscamos las que quedan de ese beneficiario
		 SELECT NVL(b.nparpla,0) + NVL(p.nparret,0)
		 INTO pnparti_actual
		 FROM benefprestaplan b, prestaplan p
		 WHERE p.sseguro = psseguro
		 AND b.sperson = psperson
		 AND p.nnivel = pnivel - 1
		 AND p.sprestaplan = b.sprestaplan;

		 pnparti_pos := 0;
	 END IF;
	 traza := 3;
	 -- Para saber el importe lo calculamos a la máxima fecha de valoracion
	 v_fvalora := Pac_Tfv.f_ultima_fval(psseguro);
	 valor_parti   := F_Valor_Participlan (v_fvalora, psseguro, DIVISA);

	 piparti_actual := ROUND(pnparti_actual * valor_parti,2);
	 piparti_pos := ROUND(pnparti_pos * valor_parti,2);

	 RETURN 0;
  EXCEPTION
      WHEN OTHERS THEN
	     p_tab_error (f_sysdate,F_USER,  'PAC_PRESTACIONES.F_calcula_participaciones',
                      traza, 'error no controlat sseguro ='||psseguro,  SQLERRM  );
	     RETURN 0;

   END f_calcula_participaciones;

 END Pac_Prestaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PRESTACIONES" TO "PROGRAMADORESCSI";
