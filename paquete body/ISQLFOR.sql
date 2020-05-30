--------------------------------------------------------
--  DDL for Package Body ISQLFOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."ISQLFOR" AS
/******************************************************************************
   NOMBRE:     ISQLFOR
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/07/2009   DCT                1. 0010612: CRE - Error en la generació de pagaments automàtics.
                                              Canviar vista personas por tablas personas y añadir filtro de visión de agente
******************************************************************************/
   FUNCTION f_persona(
      psseguro IN NUMBER DEFAULT NULL,
      pctipo IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
       -- F_PERSONA -> Devulve Apellidos y Nombre de la Persona en función del
      --              seguro y el tipo o únicamente del sperson.
      --
      --    Pctipo -> 1 Tomador, 2 Asegurado, 3 Riesgo
      nombre         VARCHAR2(100);
      vagente_poliza seguros.cagente%TYPE;
      vcempres       seguros.cempres%TYPE;
   BEGIN
      IF psseguro IS NOT NULL THEN   --- Busqueda por seguro
         --Bug10612 - 10/07/2009 - DCT (canviar vista personas)
         --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
         SELECT cagente, cempres
           INTO vagente_poliza, vcempres
           FROM seguros
          WHERE sseguro = psseguro;

         IF pctipo = 1 THEN   -- Tomador
            SELECT SUBSTR(d.tapelli1, 0, 40)
                   || DECODE(SUBSTR(d.tapelli1, 0, 40), NULL, NULL, ' ')
                   || SUBSTR(d.tapelli2, 0, 20)
                   || DECODE(SUBSTR(d.tapelli1, 0, 40) || SUBSTR(d.tapelli2, 0, 20),
                             NULL, NULL,
                             DECODE(SUBSTR(d.tnombre, 0, 20), NULL, NULL, ', '))
                   || SUBSTR(d.tnombre, 0, 20)
              INTO nombre
              FROM tomadores, per_personas p, per_detper d
             WHERE tomadores.sperson = p.sperson
               AND tomadores.sseguro = psseguro
               AND d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);
         ELSIF pctipo = 2 THEN   -- Asegurado
            SELECT SUBSTR(d.tapelli1, 0, 40)
                   || DECODE(SUBSTR(d.tapelli1, 0, 40), NULL, NULL, ' ')
                   || SUBSTR(d.tapelli2, 0, 20)
                   || DECODE(SUBSTR(d.tapelli1, 0, 40) || SUBSTR(d.tapelli2, 0, 20),
                             NULL, NULL,
                             DECODE(SUBSTR(d.tnombre, 0, 20), NULL, NULL, ', '))
                   || SUBSTR(d.tnombre, 0, 20)
              INTO nombre
              FROM asegurados, per_personas p, per_detper d
             WHERE asegurados.sperson = p.sperson
               AND asegurados.sseguro = psseguro
               AND d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);
         ELSIF pctipo = 3 THEN   -- Riesgo
            SELECT SUBSTR(d.tapelli1, 0, 40)
                   || DECODE(SUBSTR(d.tapelli1, 0, 40), NULL, NULL, ' ')
                   || SUBSTR(d.tapelli2, 0, 20)
                   || DECODE(SUBSTR(d.tapelli1, 0, 40) || SUBSTR(d.tapelli2, 0, 20),
                             NULL, NULL,
                             DECODE(SUBSTR(d.tnombre, 0, 20), NULL, NULL, ', '))
                   || SUBSTR(d.tnombre, 0, 20)
              INTO nombre
              FROM riesgos, per_personas p, per_detper d
             WHERE riesgos.sperson = p.sperson
               AND riesgos.sseguro = psseguro
               AND d.sperson = p.sperson
               AND d.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);
         END IF;
        /*IF pctipo = 1 THEN         -- Tomador
         SELECT TAPELLI1 ||
                DECODE(TAPELLI1,NULL,NULL,' ' ) ||
                   TAPELLI2 ||
               DECODE(TAPELLI1 || TAPELLI2,NULL,NULL,DECODE(TNOMBRE,NULL,NULL,', '))
               || TNOMBRE
         INTO Nombre
         FROM TOMADORES, PERSONAS
         WHERE TOMADORES.SPERSON = PERSONAS.SPERSON
         AND TOMADORES.SSEGURO = psseguro;
      ELSIF pctipo = 2 THEN       -- Asegurado
         SELECT TAPELLI1 ||
                DECODE(TAPELLI1,NULL,NULL,' ' ) ||
                   TAPELLI2 ||
               DECODE(TAPELLI1 || TAPELLI2,NULL,NULL,DECODE(TNOMBRE,NULL,NULL,', '))
               || TNOMBRE
         INTO Nombre
         FROM ASEGURADOS, PERSONAS
         WHERE ASEGURADOS.SPERSON = PERSONAS.SPERSON
         AND ASEGURADOS.SSEGURO = psseguro;
      ELSIF pctipo = 3 THEN       -- Riesgo
         SELECT TAPELLI1 ||
                DECODE(TAPELLI1,NULL,NULL,' ' ) ||
                   TAPELLI2 ||
               DECODE(TAPELLI1 || TAPELLI2,NULL,NULL,DECODE(TNOMBRE,NULL,NULL,', '))
               || TNOMBRE
         INTO Nombre
         FROM RIESGOS, PERSONAS
         WHERE RIESGOS.SPERSON = PERSONAS.SPERSON
         AND RIESGOS.SSEGURO = psseguro;
      END IF;*/

      --FI Bug10612 - 10/07/2009 - DCT (canviar vista personas)
      ELSE   --- busqueda por persona
         SELECT tapelli1 || DECODE(tapelli1, NULL, NULL, ' ') || tapelli2
                || DECODE(tapelli1 || tapelli2, NULL, NULL, DECODE(tnombre, NULL, NULL, ', '))
                || tnombre
           INTO nombre
           FROM personas
          WHERE personas.sperson = psperson;
      END IF;

      RETURN nombre;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_persona;

   FUNCTION f_domicilio(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_DOMICILIO --> Devuelve la dirección de la persona
      --                 en función del tipo de domicilio.
      domicilio      VARCHAR2(50);
   BEGIN
      SELECT tdomici
        INTO domicilio
        FROM direcciones
       WHERE direcciones.sperson = psperson
         AND direcciones.cdomici = pcdomici;

      RETURN domicilio;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_domicilio;

   FUNCTION f_codpostal(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_CODPOSTAL--> Devuelve el código postal de la persona
      --                 en función del tipo de domicilio.
      postal         VARCHAR2(5);
   BEGIN
      SELECT TO_CHAR(cpostal, 'FM00000')
        INTO postal
        FROM direcciones
       WHERE direcciones.sperson = psperson
         AND direcciones.cdomici = pcdomici;

      RETURN postal;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_codpostal;

   FUNCTION f_poblacion(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_POBLACION--> Devuelve la poblacion de la persona
      --                 en función del tipo de domicilio.
      poblacion      VARCHAR2(50);
   BEGIN
      SELECT tpoblac
        INTO poblacion
        FROM direcciones, poblaciones
       WHERE direcciones.sperson = psperson
         AND direcciones.cdomici = pcdomici
         AND direcciones.cprovin = poblaciones.cprovin
         AND direcciones.cpoblac = poblaciones.cpoblac;

      RETURN poblacion;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_poblacion;

   FUNCTION f_provincia(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_PROVINCIA--> Devuelve la PROVINCIA de la persona
      --                 en función del tipo de domicilio.
      provincia      VARCHAR2(50);
   BEGIN
      SELECT tprovin
        INTO provincia
        FROM direcciones, provincias
       WHERE direcciones.sperson = psperson
         AND direcciones.cdomici = pcdomici
         AND direcciones.cprovin = provincias.cprovin;

      RETURN provincia;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_provincia;

   FUNCTION f_profesion(psperson IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      -- F_PROFESION-> Devuelve la PROFESIÓN de la persona en función del idioma.
      profesion      VARCHAR2(50);
   BEGIN
      SELECT tprofes
        INTO profesion
        FROM profesiones, personas
       WHERE profesiones.cprofes = personas.cprofes
         AND personas.sperson = psperson
         AND profesiones.cidioma = pcidioma;

      RETURN profesion;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_profesion;

   FUNCTION f_ccc(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
      -- Devuelve el numro de CCC de una Póliza
      ccc_vin        seguros.cbancar%TYPE;
   BEGIN
      SELECT SUBSTR(cbancar, 1, 4) || '-' || SUBSTR(cbancar, 5, 4) || '-'
             || SUBSTR(cbancar, 9, 2) || '-' || SUBSTR(cbancar, 10)
        INTO ccc_vin
        FROM seguros
       WHERE sseguro = psseguro;

      RETURN ccc_vin;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;
END isqlfor;

/

  GRANT EXECUTE ON "AXIS"."ISQLFOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."ISQLFOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."ISQLFOR" TO "PROGRAMADORESCSI";
