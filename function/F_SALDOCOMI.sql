--------------------------------------------------------
--  DDL for Function F_SALDOCOMI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SALDOCOMI" (nsesion  IN NUMBER,
                                         pcempre  IN NUMBER,
                                         pfecini  IN NUMBER,
                                         pfecfin  IN NUMBER,
                                         psproduc IN NUMBER,
                                         ptipo    IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       F_SALDOCOMI
   DESCRIPCION:  Busca gastos en cuenta seguro de un producto a una fecha determinada.
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PCEMPRE(number) --> Código de la empresa
          PFECINI(Number) --> Fecha Inicio
          PFECFIN(Number) --> Fecha Fin
          SPRODUC(Number) --> Clave del Producto
          PTIPO(Number)   --> Tipo de Gasto a recuperar 28 - Gtos Internos
                                                        29 - Gtos Externos Externos
                                                        30 - Gtos Externos Internos
   RETORNA VALUE:
          VALOR(NUMBER)-----> Sumatorio
******************************************************************************/
valor    number;
pfecha   date;
xcramo   number;
xcmodali number;
xctipseg number;
xccolect number;
BEGIN
   BEGIN
     SELECT cramo,cmodali,ctipseg,ccolect
	   INTO xcramo,xcmodali,xctipseg,xccolect
       FROM PRODUCTOS
	  WHERE sproduc = psproduc;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	      RETURN NULL;
   END;
   valor := NULL;
   pfecha := to_date(pfecfin,'yyyymmdd');
   BEGIN
   SELECT sum(imovimi)
     INTO VALOR
     FROM ctaseguro
    WHERE cmovimi = ptipo
      AND fvalmov = (SELECT max(fvalmov)
                       FROM ctaseguro
                      WHERE cmovimi = ptipo
                        AND fvalmov<= PFECHA)
	  AND sseguro in (SELECT sseguro FROM seguros
	                   WHERE cramo = xcramo
					     AND cmodali = xcmodali
						 AND ctipseg = xctipseg
						 AND ccolect = xccolect);
   RETURN VALOR;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	       RETURN NULL;
     WHEN OTHERS THEN
	       RETURN NULL;
   END;
END F_SALDOCOMI;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SALDOCOMI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SALDOCOMI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SALDOCOMI" TO "PROGRAMADORESCSI";
