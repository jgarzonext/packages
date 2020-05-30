--------------------------------------------------------
--  DDL for Package PK_PROVMATEMATICAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_PROVMATEMATICAS" authid current_user  IS

-- 15/02/2007
-- ¡¡¡¡OJO!!!! este package está obsoleto
-- No se elimina pues sino descompila otros package
-- Se comenta el código obsoleto para que pueda compilar y no deje invalidos otros objetos

-- Variables Globales
  CIEPROVMAT NUMBER;
  CIEGASINTE NUMBER;
  CIEGASEXEX NUMBER;
  CIEGASEXIN NUMBER;
  FUNCTION f_cierre_provmat( psseguro IN NUMBER,
                             pfecha   IN DATE
							)RETURN NUMBER;
  FUNCTION f_cierre(   psseguro        IN NUMBER,
                       pfecha          IN DATE,
 		 			   PROVMAT 		 OUT NUMBER,
					   GASTOS_INT      OUT NUMBER,
					   GASTOS_EXT_EXT  OUT NUMBER,
					   GASTOS_EXT_INT  OUT NUMBER,
					   PRIMA_RISC      OUT NUMBER,
					   PB 		 OUT NUMBER
				  )RETURN NUMBER;

  FUNCTION f_provmat(
                       pssesion IN NUMBER,
                       psseguro IN NUMBER,
                       pfecha IN DATE,
                       ppenalitzacio IN NUMBER,
                       pImportRescat IN NUMBER DEFAULT 0
                  )RETURN NUMBER;
  FUNCTION f_matriz_provmat(
          	           psseguro IN NUMBER,
	                   fecha 	IN DATE,
	                   estat 	IN NUMBER DEFAULT 1,
 			           PROVMAT IN NUMBER  DEFAULT 0
                    )RETURN NUMBER;
  FUNCTION f_matriz_provmat9(
				       panyo IN NUMBER, 	   -- Any de calcul
  			  	       pedad IN NUMBER, 	   -- Edad primer assegurat
  				       pedad2 IN NUMBER, 	   -- Edad segon assegurat
  				       psexo IN NUMBER, 	   -- sexo del primer asegurado
  				       psexo2 IN NUMBER, 	   -- sexo del segon asegurado
  					   nduraci IN NUMBER,      -- Duració en mesos de la pòlissa
			  		   psproces IN NUMBER,	   -- Codi (No serveix per res)
  					   pinttec IN NUMBER, 	   -- Interès tècnic que s'aplica
					   piprimuni IN NUMBER,	   -- Prima unica (ve donada en la pòlissa)
					   pctiptab IN NUMBER,	   -- Codi de la taula de mortalitat
					   ppgasint IN NUMBER,	   -- Porcentatge de gastos interns (ve donat en la pòlissa)
					   picapital IN NUMBER	   -- Capital garantitzat al venciment (ve donat en la pòlissa)
			  		 )RETURN NUMBER;
  FUNCTION f_matriz_provmat10(
				panyo IN NUMBER, 		 -- Año de calculo
  				pedad IN NUMBER, 	  	 -- Edad primer asegurado
  				pedad2 IN NUMBER, 	 -- Edad segundo asegurado
				psexo IN NUMBER, 	 	 -- sexo del primer asegurado
				psexo2 IN NUMBER, 	 -- sexo del segon asegurado
				nduraci IN NUMBER,
				nduraci2 IN NUMBER,      -- Duració (en mesos) desde la data efecte fins el 31/01/2029
				psproces IN NUMBER,	 -- Codigo del proceso
			 	pinttec IN NUMBER,	 -- Interes tecnico que se aplica hasta el 2029
  				pinttec2 IN NUMBER,      -- Interes tecnico que se aplica desde el 2029 (nduraci2)
  				ppgasint IN NUMBER,	 -- Porcentage de gastos hasta el 2029
  				ppgasext IN NUMBER,	 -- Porcentatge de gastos exteriors fins el 2029
  				pprima  IN NUMBER,  	 -- Prima unica
				piprimuni IN NUMBER,	 -- Primera quantia
				piprimuni2 IN NUMBER,	 -- Segona quantia a partir, s'aplica a partir del 31/01/2029
				pctiptab IN NUMBER,	 -- Codigo de la tabla de mortalidad ( 4 )
				pmodali IN NUMBER,	 -- Codigo de la Modalidad que s'ha d'aplicar (1--> 80%, 2-->90%, 3--> 110%)
				pcdivisa IN NUMBER	 -- Codigo de la divisa
			)RETURN NUMBER;
  FUNCTION f_matriz_provmat11(
				psseguro IN NUMBER,	   -- sseguro
				panyo   IN NUMBER, 	   -- Any de calcul
				pedad   IN NUMBER, 	   -- Edad primer assegurat
				pedad2  IN NUMBER, 	   -- Edad segon assegurat
			      psexo   IN NUMBER, 	   -- sexo del primer asegurado
				psexo2  IN NUMBER, 	   -- sexo del segon asegurado
				pefecto IN DATE,		   -- fecha efecto
				pcalculo IN DATE,		   -- fecha de calculo
				nduraci  IN NUMBER,        -- Duració en mesos de la pòlissa
				nduraci1 IN NUMBER,	   -- Duració del primer periode
			  	piniciduraci2 IN NUMBER,   -- Mesos en que comença el periode 2
				nduraci2 IN NUMBER,	   -- Duració del segon periode
				nduraci3 IN NUMBER,   	   -- L'ultim periode (ja no hi han primas fraccionaris només i han prov. al morir)
				nduracicaren 	IN NUMBER, 	   -- Duració del periode de carència
				psproces  IN NUMBER,	   -- Codi (No serveix per res)
				pinttec   IN NUMBER, 	   -- Interès tècnic que s'aplica
				pgasint 	IN NUMBER,	   -- Porcentatge de gastos
				pctiptab  IN NUMBER,	   -- Codi de la taula de mortalitat
				ppgasext  IN NUMBER,	   -- Porcentatge de gastos interns (ve donat en la pòlissa)
				pfpago 	IN NUMBER, 	   -- Forma de pagament o d'amortització
				pprimafrac IN NUMBER	   -- Primes fraccionaries
		)RETURN NUMBER;
  FUNCTION f_matriz_provmat16(
				psseguro IN NUMBER,	   -- sseguro
  				panyo    IN NUMBER, 	   -- Any de calcul
				pedad    IN NUMBER, 	   -- Edad primer assegurat
				pedad2   IN NUMBER, 	   -- Edad segon assegurat
				psexo    IN NUMBER, 	   -- sexo del primer asegurado
				psexo2   IN NUMBER, 	   -- sexo del segon asegurado
				pefecto  IN DATE,		   -- fecha efecto
				pcalculo IN DATE,		   -- fecha de calculo
				nduraci  IN NUMBER,        -- Duració en mesos de la pòlissa
				nduraci1 IN NUMBER,	   -- Duració del primer periode
				piniciduraci2 IN NUMBER,   -- Mesos en que comença el periode 2
				nduraci2 IN NUMBER,	   -- Duració del segon periode
				nduraci3 IN NUMBER,   	   -- L'ultim periode (ja no hi han primas fraccionaris només i han prov. al morir)
				nduracicaren IN NUMBER,    -- Duració del periode de carència
				psproces IN NUMBER,	   -- Codi (No serveix per res)
				pinttec  IN NUMBER, 	   -- Interès tècnic que s'aplica
				pgasint  IN NUMBER,	   -- Porcentatge per gastos
				pctiptab IN NUMBER,	   -- Codi de la taula de mortalitat
				ppgasext IN NUMBER,	   -- Porcentatge de gastos interns (ve donat en la pòlissa)
				pfpago   IN NUMBER, 	   -- Forma de pagament o d'amortització
				pprimafrac IN NUMBER	   -- Primes fraccionaries
		)RETURN NUMBER;
  FUNCTION f_matriz_provmat17(
				panyo    IN NUMBER, 	   -- Any de calcul
  				pedad    IN NUMBER, 	   -- Edad primer assegurat
  				psexo    IN NUMBER, 	   -- sexo del primer asegurado
				nduraci  IN NUMBER,        -- Duració en mesos de la pòlissa
				psproces IN NUMBER,	   -- Codi (No serveix per res)
				pinttec  IN NUMBER, 	   -- Interès tècnic que s'aplica (a nivell de producte)
				piprimuni IN NUMBER,	   -- Prima unica ( Provisió matematica el dia abans del venciment de la polissa)
				pctiptab IN NUMBER,	   -- Codi de la taula de mortalitat segons el producte
				ppgasint IN NUMBER,	   -- Porcentatge de gastos interns (a nivell de producte)
				estat    IN NUMBER,   	   -- Si és un 1 --> Provisió matematica
      	   	  			   		   -- Si és un 0 --> Import brut de la renda
                psseguro IN NUMBER
		)RETURN NUMBER;
  FUNCTION F_MATRIZ_PROVMAT_ACUMULAT(
          	           PSSEGURO 	 IN NUMBER,
	                   F_CALCUL_PM 	 IN DATE
                    ) RETURN NUMBER;
  FUNCTION F_Eurospesetas (
 		        pvalor IN NUMBER,
				pcdivisa IN NUMBER) RETURN NUMBER;
END Pk_Provmatematicas;
 
 

/

  GRANT EXECUTE ON "AXIS"."PK_PROVMATEMATICAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_PROVMATEMATICAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_PROVMATEMATICAS" TO "PROGRAMADORESCSI";
