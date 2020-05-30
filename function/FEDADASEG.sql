--------------------------------------------------------
--  DDL for Function FEDADASEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FEDADASEG" (
   nsesion IN NUMBER,
   pperson IN NUMBER,
   pffecha IN NUMBER,
   ptipo IN NUMBER,
   porigen IN NUMBER DEFAULT 2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:       FEDADASEG
   DESCRIPCION:  DEVUELVE LA EDAD A UNA FECHA DETERMINADA.
   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PPERSON(number) --> Clave del asegurado
          PfFECHA(number) --> Fecha,
          PTIPO(number)   --> 1-Actuarial, 2-Real.
          porigen(number) --> 0-Tablas Sol 1-Tablas Reales 2-Tablas Estudio
   RETORNA VALUE:
          VALOR(NUMBER)-----> Edad asegurado
******************************************************************************/
   valor          NUMBER;
   xfnacimi       DATE;
   wa             NUMBER;
   pfecha         DATE;
BEGIN
   valor := NULL;
   pfecha := TO_DATE(pffecha, 'yyyymmdd');

   BEGIN
      IF porigen = 1 THEN
         -- Bug 17924 - APD - 09/03/2011 - se sustituye la tabla estpersonas por estper_personas
         SELECT fnacimi
           INTO xfnacimi
           FROM estper_personas
          WHERE sperson = pperson;
      -- Fin Bug 17924 - APD - 09/03/2011
      ELSE
         -- Bug 17924 - APD - 09/03/2011 - se sustituye la tabla personas por per_personas
         SELECT fnacimi
           INTO xfnacimi
           FROM per_personas
          WHERE sperson = pperson;
      -- Fin Bug 17924 - APD - 09/03/2011
      END IF;

      IF xfnacimi IS NOT NULL THEN
         wa := f_difdata(xfnacimi, pfecha, ptipo, 1, valor);
         RETURN valor;
      END IF;

      RETURN NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN -1;
      WHEN OTHERS THEN
         RETURN -2;
   END;
END fedadaseg;
 
 

/

  GRANT EXECUTE ON "AXIS"."FEDADASEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FEDADASEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FEDADASEG" TO "PROGRAMADORESCSI";
