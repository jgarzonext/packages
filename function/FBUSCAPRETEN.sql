--------------------------------------------------------
--  DDL for Function FBUSCAPRETEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBUSCAPRETEN" (
   psesion IN NUMBER,
   pperson IN NUMBER,
   psproduc IN NUMBER,
   pfecha IN NUMBER,
   pnsinies IN NUMBER DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:       FBUSCAPRETEN
   DESCRIPCION:  Retorna un % de I.R.P.F.

   PARAMETROS:
   INPUT: PSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PPERSON(number) --> Clave del asegurado
        PCACTPRO(number) --> Actividad Profesional. 4 = Cliente
        PFECHA(number)  --> Fecha a aplicar la retención
   RETORNA VALUE:
          VALOR(NUMBER)-----> % DE RETENCIÓN
                            NULL --> No existe en la tabla PROFESIONALES
******************************************************************************/
   valor          NUMBER;
   xcpais         NUMBER;
   xfecha         DATE;
   xcprovin       NUMBER := 0;   --SHA -- Bug 38224/216445 --11/11/2015
BEGIN
   valor := NULL;
   xfecha := TO_DATE(pfecha, 'YYYYMMDD');

--
   IF pnsinies IS NOT NULL THEN
      --MCA se incluye la búsqueda en destinatarios según país de residencia
      BEGIN
--         SELECT cpaisresid
--           INTO xcpais
--           FROM destinatarios
--          WHERE nsinies = pnsinies
--            AND sperson = pperson;
         SELECT cpaisre, cprovin   --SHA -- Bug 38224/216445 --11/11/2015
           INTO xcpais, xcprovin
           FROM sin_tramita_destinatario
          WHERE nsinies = pnsinies
            AND sperson = pperson;
      EXCEPTION
         WHEN OTHERS THEN
            BEGIN
               SELECT cpais
                 INTO xcpais
                 FROM personas
                WHERE sperson = pperson;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN NULL;
            END;
      END;
   ELSE
      BEGIN
         SELECT cpais
           INTO xcpais
           FROM personas
          WHERE sperson = pperson;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;
   END IF;

--
   IF xcpais IS NULL THEN
      BEGIN
         SELECT cpais
           INTO xcpais
           FROM direcciones d, provincias p
          WHERE p.cprovin = d.cprovin
            AND d.sperson = pperson
            AND cdomici = (SELECT MIN(cdomici)
                             FROM direcciones
                            WHERE sperson = pperson);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;
   END IF;

   IF xcprovin IS NULL THEN   --SHA -- Bug 38224/216445 --11/11/2015
      BEGIN
         SELECT p.cprovin
           INTO xcprovin
           FROM direcciones d, provincias p
          WHERE p.cprovin = d.cprovin
            AND d.sperson = pperson
            AND cdomici = (SELECT MIN(cdomici)
                             FROM direcciones
                            WHERE sperson = pperson);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;
   END IF;

   BEGIN
      SELECT pretenc
        INTO valor
        FROM paisprete
       WHERE cpais = xcpais
         AND sproduc = psproduc
         AND cprovin = xcprovin   -- SHA -- Bug 38224/216445 --11/11/2015
         AND finicio = (SELECT MAX(finicio)
                          FROM paisprete
                         WHERE cpais = xcpais
                           AND sproduc = psproduc
                           AND cprovin = xcprovin   -- SHA -- Bug 38224/216445 --11/11/2015
                           AND finicio <= xfecha);

      RETURN valor;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         BEGIN
            SELECT pretenc
              INTO valor
              FROM paisprete
             WHERE cpais = xcpais
               AND cprovin =
                     0   -- SHA -- Bug 38224/216445 --11/11/2015: Si no hemos encontraod retencion definida para la provincia, vamos por defecto
               AND sproduc = psproduc
               AND finicio = (SELECT MAX(finicio)
                                FROM paisprete
                               WHERE cpais = xcpais
                                 AND cprovin = 0   -- SHA -- Bug 38224/216445 --11/11/2015
                                 AND sproduc = psproduc
                                 AND finicio <= xfecha);

            RETURN valor;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT pretenc
                    INTO valor
                    FROM retenciones
                   WHERE cretenc = 3   -- Pers.Fis.No Residentes
                     AND finivig = (SELECT MAX(finivig)
                                      FROM retenciones
                                     WHERE cretenc = 3   -- Pers.Fis.No Residentes
                                       AND finivig <= xfecha);

                  RETURN valor;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN NULL;
               END;
            WHEN OTHERS THEN
               RETURN NULL;
         END;
      WHEN OTHERS THEN
         RETURN NULL;
   END;
END fbuscapreten;

/

  GRANT EXECUTE ON "AXIS"."FBUSCAPRETEN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBUSCAPRETEN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBUSCAPRETEN" TO "PROGRAMADORESCSI";
