--------------------------------------------------------
--  DDL for Function F_ESTADO_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTADO_PP" ( psseguro IN NUMBER ) RETURN NUMBER  IS

-- ********************************************************************************
-- Devuelve el estado de la póliza de un plan.
--********************************************************************************
num_err NUMBER;
situac NUMBER;
cuantos NUMBER;
BEGIN
              SELECT CSITUAC INTO situac
			  FROM SEGUROS
			  WHERE SEGUROS.sseguro = psseguro;


               num_err := F_Vigente(psseguro,NULL,F_Sysdate);

			   IF situac = 5 THEN
			          RETURN 101481; -- Propuesta de suplemento;
			   END IF;

               IF num_err <> 0 THEN
			                  IF situac = 1 THEN
							     		   	 	 RETURN 101480;  --Póliza suspendida
			                  ELSIF situac = 2 THEN
							     			  	 RETURN 101483;		-- Póliza anulada
			                  ELSIF situac = 3 THEN
							  				     RETURN 101483;			--Poliza vencida
			                  ELSIF situac = 4 THEN
							  					RETURN 101666;     -- Propuesta alta
			                  ELSIF situac = 5 THEN
							  					RETURN 101481; -- Propuesta suplemento
			                  ELSE
							                    RETURN num_err; -- Otros valores
			                  END IF;
				END IF;

				-- Miramos si tiene parte de prestaciones activas
                  SELECT COUNT(*) INTO CUANTOS
                  FROM PRESTAPLAN
                  WHERE sseguro = psseguro
                  AND cestado <> 3; --(1-inactiva, 2 -En procés)

                  IF CUANTOS > 0 THEN
				        RETURN 109432; -- El contrato ya tiene prestaciones en ejecución.
                  END IF;



 RETURN 0;

 EXCEPTION
 WHEN OTHERS THEN
   RETURN -1;  -- Error no controlado;

END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESTADO_PP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTADO_PP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTADO_PP" TO "PROGRAMADORESCSI";
