--------------------------------------------------------
--  DDL for Function F_DIRDELE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DIRDELE" (
   pcdelega IN NUMBER,
   pcformat IN NUMBER,
   ptlin1 OUT VARCHAR2,
   ptlin2 OUT VARCHAR2,
   ptlin3 OUT VARCHAR2,
   ptlin4 OUT VARCHAR2,
   ptlin5 OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_DIRDELE:  Retorna la dirección de una delegación entrando su
código.
La variable PCFORMAT indica el tipo de formato ( de
momento sólo existe el pcformat 1 ).
Devuelve 5 líneas con la dirección.
   ALLIBMFM

***********************************************************************/
   error          NUMBER := 0;
   xpersona       NUMBER(6);
   xcdomici       NUMBER;
   xtdomici       VARCHAR2(40);
   xcpostal       codpostal.cpostal%TYPE;   -- canvi format codi postal
   xcpoblac       poblaciones.cpoblac%TYPE;
   xcprovin       provincias.cprovin%TYPE;
   xpoblacio      VARCHAR2(50);
   xtelefono      VARCHAR2(30);
   xfax           VARCHAR2(30);
   xemail         VARCHAR2(30);
BEGIN
   IF pcdelega IS NOT NULL THEN
      IF pcformat = 1 THEN
         BEGIN
            SELECT sperson, cdomici
              INTO xpersona, xcdomici
              FROM agentes
             WHERE cagente = pcdelega;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 104472;   -- Agent no trobat a AGENTES
            WHEN OTHERS THEN
               RETURN 104473;   -- Error al llegir de AGENTES
         END;

         BEGIN
            SELECT tdomici, cpostal, cpoblac, cprovin
              INTO xtdomici, xcpostal, xcpoblac, xcprovin
              FROM direcciones
             WHERE sperson = xpersona
               AND cdomici = xcdomici;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 104475;   -- Adreça no trobada a DIRECCIONES
            WHEN OTHERS THEN
               RETURN 104474;   -- Error al llegir de DIRECCIONES
         END;

         BEGIN
            SELECT tvalcon
              INTO xtelefono
              FROM contactos
             WHERE sperson = xpersona
               AND ctipcon = 1
               AND cmodcon = (SELECT MIN(cmodcon)
                                FROM contactos
                               WHERE sperson = xpersona
                                 AND ctipcon = 1);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               RETURN 104476;   -- Error al llegir de CONTACTOS
         END;

         BEGIN
            SELECT tvalcon
              INTO xfax
              FROM contactos
             WHERE sperson = xpersona
               AND ctipcon = 2
               AND cmodcon = (SELECT MIN(cmodcon)
                                FROM contactos
                               WHERE sperson = xpersona
                                 AND ctipcon = 2);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               RETURN 104476;   -- Error al llegir de CONTACTOS
         END;

         BEGIN
            SELECT tvalcon
              INTO xemail
              FROM contactos
             WHERE sperson = xpersona
               AND ctipcon = 3
               AND cmodcon = (SELECT MIN(cmodcon)
                                FROM contactos
                               WHERE sperson = xpersona
                                 AND ctipcon = 3);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               RETURN 104476;   -- Error al llegir de CONTACTOS
         END;

         error := f_despoblac(xcpoblac, xcprovin, xpoblacio);

         IF error = 0 THEN
            ptlin1 := xtdomici;
            ptlin2 := xcpostal || ' ' || xpoblacio;
            ptlin3 := 'Tel. ' || xtelefono;
            ptlin4 := 'Fax. ' || xfax;
            ptlin5 := 'E-mail ' || xemail;
            RETURN 0;
         ELSE
            RETURN error;
         END IF;
      ELSE
         RETURN 101901;   -- Error en la introducció de paràmetres
      END IF;
   ELSE
      RETURN 101901;   -- Error en la introducció de paràmetres
   END IF;
END;

/

  GRANT EXECUTE ON "AXIS"."F_DIRDELE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DIRDELE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DIRDELE" TO "PROGRAMADORESCSI";
