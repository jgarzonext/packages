--------------------------------------------------------
--  DDL for Function F_ES_VINCULADA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ES_VINCULADA" ( psseguro IN NUMBER, pnriesgo IN NUMBER DEFAULT 1,
             pfecha in date default null) RETURN NUMBER IS
/******************************************************************************
Función que nos indica si una póliza está vinculada a un préstamo
 1.- indica que si,
 0.- indica que no

 -- Cada instalación tendrá su función para identificar las pólizas vinculadas
******************************************************************************/
 sufijo		varchar2(100);
 funcion	varchar2(100);
 s			varchar2(1000);
 num_err	number;
BEGIN
  sufijo := f_parinstalacion_t('SUFIJ_PERS');

  funcion := 'f_es_vinculada_'||sufijo;

  s := 'begin :num_err := '|| funcion|| '(:psseguro, :pnriesgo, :pfecha); end;';

  EXECUTE IMMEDIATE s  USING OUT    num_err,
    	  			   		  IN     psseguro,
							  IN 	 pnriesgo,
                              IN     pfecha;

  return num_err;

exception
   when others then
      p_tab_error (f_sysdate, F_USER, 'f_es_vinculada', 1,'when others SSEGURO ='
                      || psseguro
                      || ' PFECHA='
                      || pfecha
                      || ' funcion ='
                      || funcion,
                      SQLERRM
                     );
         RETURN 108953;
              -- error de ejecución
END f_es_vinculada;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ES_VINCULADA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ES_VINCULADA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ES_VINCULADA" TO "PROGRAMADORESCSI";
