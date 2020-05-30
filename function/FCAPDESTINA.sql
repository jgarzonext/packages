--------------------------------------------------------
--  DDL for Function FCAPDESTINA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FCAPDESTINA" (nsesion  IN NUMBER,
                                 pnsinies IN NUMBER,
          pctipdes IN NUMBER,
          pcapnrod IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:
   DESCRIPCION:  Importe QUE SE HA ASIGNADO A un tipo de destinatario.
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PNSINIES(number) --> Nro. de siniestro.
    PCTIPDES(number)  --> Tipo de destinatario.
    PCAPNROD(NUMBER)  --> 1 NRO. DE DESTINATARIOS del tipo escogido.
             2 Suma total de importe bruto.
   RETORNA VALUE:
          NUMBER------------> Retorna el Importe asignado
******************************************************************************/
valor     NUMBER;
BEGIN
   valor := 0;
   IF PCAPNROD = 1 THEN
      BEGIN
       SELECT COUNT(CTIPDES)
       INTO VALOR
       FROM DESTINATARIOS
      WHERE CTIPDES=PCTIPDES
        AND NSINIES= PNSINIES;
	  IF VALOR IS NULL THEN
	     RETURN 0;
	  ELSE
	    RETURN VALOR;
      END IF;
   	 EXCEPTION
       WHEN OTHERS THEN
        RETURN 0;
   	 END;
   ELSE
      BEGIN
	    SELECT NVL(SUM(DECODE(ctippag, 2, isinret,
		                               8, isinret, isinret * -1)),0)
          INTO VALOR
          FROM PAGOSINI
         WHERE NSINIES = PNSINIES
       	   AND CTIPDES= PCTIPDES
           AND CESTPAG <> 8;
		IF VALOR IS NULL THEN
		    RETURN 0;
		ELSE
  			RETURN VALOR;
		END IF;
   	  EXCEPTION
       WHEN OTHERS THEN
	   		RETURN 0;
      END;
   END IF;
END Fcapdestina;
 
 

/

  GRANT EXECUTE ON "AXIS"."FCAPDESTINA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FCAPDESTINA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FCAPDESTINA" TO "PROGRAMADORESCSI";
