--------------------------------------------------------
--  DDL for Function F_DIRECORRE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DIRECORRE" (
   psperson IN NUMBER,
   pcdomici IN NUMBER,
   pnif OUT VARCHAR2,
   pdire OUT VARCHAR2,
   ppobla OUT VARCHAR2,
   pcpostal OUT codpostal.cpostal%TYPE,   --3606 jdomingo 29/11/2007  canvi format codi postal
   ptelefono OUT VARCHAR2,
   pfax OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/*******************************************************************
F_DIRECORRE: Retorna el nif, una adreça, tfno. i fax del prenedor o
assegurat d'un seguro, per enviar-lo a la Correduría
del Banc de Sabadell.
   ALLIBMFM
*******************************************************************/
   codi_error     NUMBER := 0;
   wpoblac        poblaciones.cpoblac%TYPE;
   wcprovin       provincias.cprovin%TYPE;
BEGIN
   BEGIN
      SELECT nnumnif
        INTO pnif
        FROM personas
       WHERE sperson = psperson;
   EXCEPTION
      WHEN OTHERS THEN
         codi_error := 1;
         RETURN(codi_error);
   END;

   BEGIN
      SELECT tdomici, cpostal, cpoblac, cprovin
        INTO pdire, pcpostal, wpoblac, wcprovin
        FROM direcciones
       WHERE sperson = psperson
         AND cdomici = pcdomici;
   EXCEPTION
      WHEN OTHERS THEN
         codi_error := 2;
         RETURN(codi_error);
   END;

   BEGIN
      SELECT tpoblac
        INTO ppobla
        FROM poblaciones
       WHERE cpoblac = wpoblac
         AND cprovin = wcprovin;
   EXCEPTION
      WHEN OTHERS THEN
         codi_error := 3;
         RETURN(codi_error);
   END;

   BEGIN
      SELECT tvalcon
        INTO ptelefono
        FROM contactos
       WHERE sperson = psperson
         AND ctipcon = 1
         AND cmodcon = (SELECT MIN(cmodcon)
                          FROM contactos
                         WHERE sperson = psperson
                           AND ctipcon = 1);
   EXCEPTION
      WHEN OTHERS THEN
         ptelefono := NULL;
   END;

   BEGIN
      SELECT tvalcon
        INTO pfax
        FROM contactos
       WHERE sperson = psperson
         AND ctipcon = 2
         AND cmodcon = (SELECT MIN(cmodcon)
                          FROM contactos
                         WHERE sperson = psperson
                           AND ctipcon = 2);
   EXCEPTION
      WHEN OTHERS THEN
         pfax := NULL;
   END;

   RETURN(codi_error);
END;

/

  GRANT EXECUTE ON "AXIS"."F_DIRECORRE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DIRECORRE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DIRECORRE" TO "PROGRAMADORESCSI";
