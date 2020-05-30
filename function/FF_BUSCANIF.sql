--------------------------------------------------------
--  DDL for Function FF_BUSCANIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_BUSCANIF" (psperson IN NUMBER)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/************************************************************************************
    11/07/2007: APD
    Ff_BuscaNIF: Función que dado un sperson, devuelve el NIF de la persona
    REVISIONES:
      Ver        Fecha       Autor  Descripci?n
      ---------  ----------  -----  ------------------------------------
      1.0                           Creaci?n del package.
      2.0        15/04/2014  JMG    2. 0030819:172481 LCOL896-Soporte a cliente en Liberty (Abril 2014)
*************************************************************************************/
   v_nif          VARCHAR2(14);
BEGIN
--Bug 30819 - 15/04/2012 - JMG -  Se aplica validación por per_personas.
   SELECT nnumide
     INTO v_nif
     FROM per_personas
    WHERE sperson = psperson;

   RETURN(v_nif);
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_USER, 'Ff_BuscaNIF', NULL, 180423, 'Error Ff_BuscaNIF');
      RETURN(NULL);
END;

/

  GRANT EXECUTE ON "AXIS"."FF_BUSCANIF" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_BUSCANIF" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_BUSCANIF" TO "PROGRAMADORESCSI";
