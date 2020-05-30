--------------------------------------------------------
--  DDL for Function F_ESCOMISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ESCOMISION" ( PCONCEPT IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /****************************************************************************
   	F_ESCOMISION: Dice si un concepto se puede interpretar como una comisión
   	Devuelve 1 si lo es, 0 en otro caso
   ****************************************************************************/
     W_NUM_AUX		NUMBER(10);
   BEGIN
     SELECT COUNT(*)
     INTO   W_NUM_AUX
     FROM   CALCOMISION
     WHERE   	 CCONCEPT = PCONCEPT;
     IF W_NUM_AUX > 0 THEN
       RETURN 1;
     END IF;
     RETURN 0;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN 0;
     WHEN OTHERS THEN
       RETURN 0;
   END F_Escomision;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ESCOMISION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ESCOMISION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ESCOMISION" TO "PROGRAMADORESCSI";
