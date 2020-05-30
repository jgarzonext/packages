--------------------------------------------------------
--  DDL for Function FEDAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FEDAD" (nsesion  IN NUMBER,
       	  		                  pfnacimi  IN NUMBER,
                                  pffecha  IN NUMBER,
                                  ptipo    IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FEDAD
   DESCRIPCION:  DEVUELVE LA EDAD A UNA FECHA DETERMINADA.
   REVISIONES:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/6/2004    YIL			   CREACION DE LA FUNCIÓN
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PFNACIMI(number) --> Fecha de nacimiento
          PfFECHA(number) --> Fecha,
          PTIPO(number)   --> 1-Real, 2-Actuarial
   RETORNA VALUE:
          VALOR(NUMBER)-----> Edad
******************************************************************************/
valor    number;
xfnacimi date;
wa       number;
pfecha   date;
pfnac    date;
BEGIN
   valor := NULL;
   if pffecha is null or pfnacimi is null then
      -- p_control_error(null, 'f_edad',
      -- 'PFECHA O PFNACIMI IS NULL  PFECHA='||PFFECHA||' PFNACIMI ='||PFNACIMI);
       RETURN -1;
   else
      pfecha := to_date(pffecha,'yyyymmdd');
      xfnacimi := to_date(pfnacimi, 'yyyymmdd');

      WA := F_DIFDATA(xfnacimi,pfecha,ptipo,1,valor);
	  RETURN VALOR;
   end if;
END FEDAD;
 
 

/

  GRANT EXECUTE ON "AXIS"."FEDAD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FEDAD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FEDAD" TO "PROGRAMADORESCSI";
