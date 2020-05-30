--------------------------------------------------------
--  DDL for Function FCALCUL_FORMULAS_PROVI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FCALCUL_FORMULAS_PROVI" (nsesion  IN NUMBER,
                                        psseguro  IN NUMBER,
                                        pfecha   IN number,
                                        pcampo   IN VARCHAR2)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:
   DESCRIPCION:   Se crea esta función para poder utilizar el pac_provmat_formul.f_calcul_formulas_provi
      desde el GFI (No se puede utilizar porque el nombre de la función es demasiado largo).
      pac_provmat_formul.f_calcul_formulas_provi ==> Función que mira qué fórmula se tiene que ejecutar dependiendo del parámetro
       de GARANFORMULA (valor del parámetro pcampo). Una vez tiene esta fórmula (clave), la ejecuta
       a través de la función PAC_CALCULO_FORMULAS.CALC_FORMUL y el resultado de este cálculo es lo
       que devuelve la función. Si la póliza no está vigente (está anulada) la función devuelve 0.
       Si no se encuentra ninguna fórmula asociada la función devuelve null.

   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSEGURO(number) --> secuencia del seguro que se está consultando
		  PFECHA(number)  --> Fecha de consulta.
          PCAMPO (VARCHAR2) --> Campo para el cual ejecutaremos la formula (p.e. 'ICFALLAC', 'IPROVAC'
   RETORNA VALUE:
          NUMBER------------> Resultado de la fórmula
******************************************************************************/

BEGIN
     return pac_provmat_formul.f_calcul_formulas_provi(psseguro, to_date(pfecha,'yyyymmdd'), pcampo);
END FCALCUL_FORMULAS_PROVI;
 
 

/

  GRANT EXECUTE ON "AXIS"."FCALCUL_FORMULAS_PROVI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FCALCUL_FORMULAS_PROVI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FCALCUL_FORMULAS_PROVI" TO "PROGRAMADORESCSI";
