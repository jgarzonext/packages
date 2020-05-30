--------------------------------------------------------
--  DDL for Function F_MATEMBARCACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_MATEMBARCACIONES" (pmatric  IN embarcriesgos.tmatric%TYPE,
						psseguro IN embarcriesgos.sseguro%TYPE,v_vigente IN OUT NUMBER,v_suspendida IN OUT NUMBER,
						v_anulada IN OUT NUMBER,v_vencida IN OUT NUMBER,v_prop IN OUT NUMBER,
						v_propanul IN OUT NUMBER,v_propsuple IN OUT NUMBER,v_propbaja IN OUT NUMBER,
						v_estudio IN OUT NUMBER,pcretorn OUT NUMBER)
RETURN NUMBER   IS

/**************************************************************************************
Funció que comprova que la matricula o sseguro de entrada estigui en situació correcte
per fer una proposta.

Debido al sistema de  vistas,sinónimos ... que se utiliza en PTY es necesario para el
correcto funcionamiento de esta función que no tenga 'authid current_user' para que cualquier
usuario (con o sin delegación) pueda ver la tabla seguros sin filtros.

	SITUACIÓ	LIETRAL DE RETORN RETORN
	0 - Vigente	109917	-	Hay una póliza vigente con la misma matrícula
                                        Hi ha una pòlissa vigent amb la mateixa matrícula

	1 - Susependida	109918	-	Hay una póliza suspendida con la misma matrícula
                                        Hi ha una pòlissa suspesa amb la mateixa matrícula
	2 - Anulada	112209	-	Hay una póliza anulada con la misma matrícula
	3 - Vencida	0	-

	4 - Prop.Alta	109919	-	Hay una póliza en propuesta de alta con la misma matrícula
                                        Hi ha una pòlissa en proposta d'alta amb la mateixa matrícula
        8-              112210         Hay una póliza en propuesta de alta anulada o no aceptada con la misma matrícula.
	5 - Prop.suple	109920	-	Hay una póliza en propuesta de suplemento con la misma matrícula
                                        Hi ha una pòlissa en proposta de suplement amb la mateixa matrícula

	6 - Prop.baja	109921	-	Hay una póliza en propuesta de baja con la misma matrícula
                                        Hi ha una pòlissa en proposta de baixa amb la mateixa matrícula

	7 - Estudio	109922	-	Hay una póliza en estudio con la misma matrícula
                                        Hi ha una pòlissa en estudi amb la mateixa matrícula

***************************************************************************************/
  wko  NUMBER;
  wcsituac  seguros.csituac%TYPE;
  wcreteni  seguros.creteni%TYPE;
  v_nmatric  embarcriesgos.tmatric%TYPE;
  v_sseguro seguros.sseguro%TYPE;

  CURSOR c_autriesgos IS           /* sseguros de una matrícula */
    SELECT DISTINCT a.sseguro
    FROM embarcriesgos a, riesgos r
    WHERE a.sseguro = r.sseguro
     AND a.nriesgo = r.nriesgo
     AND r.fanulac IS NULL
     AND tmatric = pmatric
     AND r.sseguro <> psseguro;

BEGIN

    BEGIN
     FOR c1 IN c_autriesgos LOOP
      wko := 0;
     wcsituac := NULL;
      IF wko = 0 THEN
        BEGIN
         SELECT csituac, creteni INTO wcsituac, wcreteni
	 FROM seguros
	 WHERE sseguro = c1.sseguro;
          EXCEPTION
           WHEN NO_DATA_FOUND THEN
           wko := 0;
           WHEN OTHERS THEN
           RETURN SQLCODE;
        END;
       IF  wcsituac = 3 OR wcsituac IS NULL THEN
         wko := 0;
       ELSE
         wko := 1;
         v_sseguro := c1.sseguro;
       END IF;
     END IF;
      IF wko = 1 THEN
       IF wcsituac = 0 THEN
          SELECT A1.tmatric
          INTO v_nmatric
          FROM embarcriesgos A1
          WHERE A1.sseguro = v_sseguro
              AND A1.nmovimi = (SELECT MAX(A2.nmovimi)
                                       FROM embarcriesgos A2
                                       WHERE A2.sseguro = A1.sseguro);
          IF  v_nmatric = pmatric THEN
           pcretorn := 109917;     /*Vigente*/
           v_vigente := v_vigente + 1;
          ELSE
           pcretorn := 0;
          END IF;
       ELSIF wcsituac = 1 THEN
         v_suspendida := v_suspendida + 1;
         pcretorn := 109918;    /*Susependida*/
       ELSIF wcsituac = 2 THEN
         pcretorn := 112286;   /*Anulada*/  /*Ya existe una operación con esta matrícula.Consultar con central.*/
         v_anulada := v_anulada +1;
       ELSIF wcsituac = 4 THEN
         IF wcreteni NOT IN (3,4) THEN
          pcretorn := 109919;    /*Propuesta de alta*/
          v_prop := v_prop + 1;
         END IF;
         IF wcreteni IN (3,4) THEN
          pcretorn := 112286;    /*Propuesta de alta anulada o no aceptada*/ /* Ya existe una operación con esta matrícula.Consultar con central.*/
          v_propanul :=   v_propanul +1;
         END IF;
       ELSIF wcsituac = 5 THEN
         pcretorn := 109920;    /*Propuesta de suplemento*/
         v_propsuple := v_propsuple +1;
       ELSIF wcsituac = 6 THEN
         pcretorn := 109921;    /*Propuesta de baja*/
         v_propbaja :=  v_propbaja+1;
       ELSIF wcsituac = 7 THEN
         pcretorn := 109921;    /*Estudio*/
         v_estudio := v_estudio +1;
       ELSE
         pcretorn := 0;
       END IF;
     END IF;
   END LOOP;
   EXCEPTION
   WHEN OTHERS THEN
     RETURN SQLCODE;
   END;
RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_MATEMBARCACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_MATEMBARCACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_MATEMBARCACIONES" TO "PROGRAMADORESCSI";
