--------------------------------------------------------
--  DDL for Function F_ESTADOREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESTADOREC" (pnrecibo IN NUMBER, pfecha IN DATE)
	   	  RETURN NUMBER IS
/*****************************************************************************
  DEvuelve el estado de un recibo a una fecha determinada
*****************************************************************************/

	estado NUMBER;
BEGIN

	 SELECT cestrec
	   INTO estado
	   FROM movrecibo
	  WHERE nrecibo = pnrecibo
	    AND smovrec = (SELECT MAX(smovrec)
		                 FROM movrecibo
						WHERE nrecibo = pnrecibo
						  AND fmovini <= pfecha);

     RETURN estado;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN Null;
     WHEN OTHERS THEN
       RETURN Null;
END F_ESTADOREC;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESTADOREC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESTADOREC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESTADOREC" TO "PROGRAMADORESCSI";
