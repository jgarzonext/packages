--------------------------------------------------------
--  DDL for Function F_DURACION_CAMPANYA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DURACION_CAMPANYA" (
   pccampanya NUMBER,
   pnversio NUMBER,
   psproduc NUMBER,
   pcactivi NUMBER,
   pcgarant NUMBER,
   psseguro NUMBER,
   pnriesgo NUMBER,
   pnmovima NUMBER,
   pfefecto DATE,
   pmeses OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
    /***********************************************************************************
     Función que calcula la duración de descuentos de campaña que se
      aplicará a un riesgo dado
     Modificamos los literales de los errores que se devuelven
     Comentado en la select la condicion
         --  AND g.ccampanya = pccampanya
         -- AND g.nversio = pnversio
       para el correcto comportamiento de los dtos de campanya en los suplementos,
       como se mira si de ha dado de baja, la duración de la campanya no funciona
       ya que no esta en garanseg, pero trabajamos con la fecha de como si fuese
       vigente.
     añadimos un nuevo parametro (pfefecto) para indicar la fecha
       en que se dio de alta la garantía.
   ***********************************************************************************/
   vfiniefe       DATE;
   vfnacimi       DATE;
   vcduraci       NUMBER;
   vnmeses        NUMBER;
   vnedalim       NUMBER;
   --
   vmestotal      NUMBER;
   vmestiene      NUMBER;
   vmesfalta      NUMBER;
   vagente_poliza seguros.cagente%TYPE;
   vcempres       seguros.cempres%TYPE;
---
BEGIN
   --obtenemos la fecha de efecto del último movimiento de la poliza
   BEGIN
      SELECT m.fefecto
        INTO vfiniefe
        FROM garanseg g, movseguro m
       WHERE g.sseguro = psseguro
         AND g.nriesgo = pnriesgo
         AND g.cgarant = pcgarant
         AND g.ccampanya = pccampanya
         AND g.nversio = pnversio
         AND g.nmovima = pnmovima
         AND m.sseguro = g.sseguro
         AND m.nmovimi = g.nmovima;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 112112;
      --Campanya inexistent
      WHEN OTHERS THEN
          --DBMS_OUTPUT.put_line(psseguro || '.' || pnriesgo || '.' || pcgarant || '.'
         --                      || pccampanya || '.' || pnversio || '.' || pnmovima);
          --DBMS_OUTPUT.put_line(SQLERRM);
         RETURN 107839;
   --error al pas de parametres
   END;

   --obtenemos el el tipo de duración de la campanya de  detcampanya
   --así como los meses y edades limites
   BEGIN
      SELECT cduraci, nmeses, nedalim
        INTO vcduraci, vnmeses, vnedalim
        FROM detcampanya d
       WHERE ccampanya = pccampanya
         AND nversio = pnversio
         AND sproduc = psproduc
         AND cactivi = pcactivi
         AND cgarant = pcgarant;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 112112;
      WHEN OTHERS THEN
         RETURN 112112;
   END;

   --calculamos los meses
   IF vcduraci IN(2, 3) THEN
      --buscamos la fecha limite en que se anula la campanya por edad limite
      BEGIN
         -- Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
         --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
         SELECT p.fnacimi
           INTO vfnacimi
           FROM per_personas p, riesgos r
          WHERE r.sseguro = psseguro
            AND r.nriesgo = pnriesgo
            AND p.sperson = r.sperson;
      /*SELECT fnacimi
        INTO vfnacimi
        FROM personas p, riesgos r
       WHERE r.sseguro = psseguro
         AND r.nriesgo = pnriesgo
         AND p.sperson = r.sperson;*/

      -- FI Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 105113;   --persona no trobada a la taula personas
         WHEN OTHERS THEN
            RETURN 105113;
      END;

      vmestotal := (vnedalim + 1) * 12;

      --meses que tiene el riesgo cuando se anula incluye el año en que cumple
      --la edad maxima-
      IF vfnacimi < pfefecto THEN
         --DBMS_OUTPUT.put_line(vfnacimi);
         vmestiene := MONTHS_BETWEEN(TO_DATE(TO_CHAR(pfefecto, 'mmyyyy'), 'mmyyyy'),
                                     TO_DATE(TO_CHAR(vfnacimi, 'mmyyyy'), 'mmyyyy'));   --meses que tiene
      ELSE
         RETURN 105981;
      END IF;

      --sumamos 1 para que incluya el mes del cumpleaños tambíen lo incluya.
      vmesfalta :=(vmestotal - vmestiene);   -- + 1; --mes que le faltan
   END IF;

   IF vcduraci = 0 THEN
      pmeses := NULL;
   ELSIF vcduraci = 1 THEN
      pmeses := ROUND(vnmeses);
   ELSIF vcduraci = 2 THEN
      pmeses := ROUND(vmesfalta);
   ELSIF vcduraci = 3 THEN
      IF vnmeses <= vmesfalta THEN
         pmeses := ROUND(vnmeses);
      ELSE
         pmeses := ROUND(vmesfalta);
      END IF;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 112148;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DURACION_CAMPANYA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DURACION_CAMPANYA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DURACION_CAMPANYA" TO "PROGRAMADORESCSI";
