--------------------------------------------------------
--  DDL for Function F_TOMADOR2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TOMADOR2" (
   psseguro   IN       NUMBER,
   pnordtom   IN       NUMBER,
   ptnombre   IN OUT   VARCHAR2,
   pcidioma   IN OUT   NUMBER,
   ppersona   IN OUT   NUMBER,
   pdomici    IN OUT   NUMBER
)
   RETURN NUMBER AUTHID CURRENT_USER
IS
/***********************************************************************
    F_TOMADOR2 : Retorna el nombre, idioma, código de persona y
código de domicilio del Tomador de la
                 póliza a partir de su número.
    ALLIBCTR - Gestión de datos referentes a los seguros
***********************************************************************/
   pinstalacion   VARCHAR2 (100);
BEGIN
--BUSCAMOS LA INSTALACION
   BEGIN
      SELECT UPPER (tvalpar)
        INTO pinstalacion
        FROM parinstalacion
       WHERE UPPER (cparame) = 'GRUPO';
   EXCEPTION
      WHEN OTHERS
      THEN
         pinstalacion := '';
   END;

   BEGIN
      SELECT f_nombre(t.sperson,1,s.cagente) tnombre ,
               s.cidioma cidioma,
               t.sperson, t.cdomici
        INTO ptnombre, pcidioma, ppersona, pdomici
          FROM TOMADORES t, SEGUROS s
         WHERE t.nordtom = pnordtom
           AND t.sseguro = psseguro
           AND s.sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         ptnombre := '**';
         RETURN 0;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      ' F_TOMADOR2',
                      NULL,
                      'F_TOMADOR2(' || psseguro || ',' || pnordtom || ')',
                      SQLERRM
                     );
         RETURN 100524;                                  -- Tomador inexistent
   END;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_TOMADOR2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TOMADOR2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TOMADOR2" TO "PROGRAMADORESCSI";
