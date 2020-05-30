  CREATE OR REPLACE FUNCTION "AXIS"."F_SNNUMNIF" (pnnumnif IN VARCHAR2, znnumnif OUT VARCHAR2)
   RETURN VARCHAR2 IS
/***************************************************************************
   F_SNNUMNIF: CUANDO SE INTRODUCE UNA Z COMO NIF, AUTOM¿TICAMENTE SE LE
         DA EL VALOR DE LA SECUENCIA (EJ. ZZ0000000);
   ALLIBMFM.
   Modificaci¿: EN VEZ DE UTILIZAR LA SECUENCIA SNUMNIF SE UTILIZA LA
                SECUENCIA SPERSON
    Modificaci¿: Es fa servir la secuencia snip en comptes de la sperson
    Modificaci¿: Es canvia el format de l'identificador del sistema
	4.0  IAXIS-3060  CES    Ajuste Codigo identificacion del sistema Consorcios.
  5.0  IAXIS-4832(4)  DFR    Refinamiento revision final 
****************************************************************************/
   secuencia      VARCHAR2(20);
   format_secuen  VARCHAR2(20);
BEGIN
--INI-IAXIS-3060-CES 
   IF SUBSTR(pnnumnif, 1, 1) = '9'
      AND LENGTH(pnnumnif) = 1 THEN
--END-IAXIS-3060-CES 				 
       /*SELECT SNUMNIF.NEXTVAL INTO SECUENCIA
      FROM DUAL;*/
      /*--5/1/1999 YIL. SE UTILIZA LA SECUENCIA SPERSON
      SELECT SPERSON.NEXTVAL INTO SECUENCIA
      FROM DUAL;*/
         --12/12/2008 JTS
      SELECT snip.NEXTVAL
        INTO secuencia
        FROM DUAL;

--INI-IAXIS-3060-CES 
      format_secuen := LPAD(secuencia, 10, '0');
      znnumnif := '99' || format_secuen;
--END-IAXIS-3060-CES 
   --ELSIF LENGTH(PNNUMNIF) > 1 and SUBSTR(PNNUMNIF,1,1) = 'Z' THEN
   -- RETURN 103124;  ---ESCRIBIR S¿LO LA Z
   ELSIF SUBSTR(pnnumnif, 1, 1) = '4'
         AND LENGTH(pnnumnif) = 1 THEN
      SELECT scodperext.NEXTVAL
        INTO secuencia
        FROM DUAL;

      znnumnif :=44444 || '' || secuencia;
   --   
   -- Inicio IAXIS-4832(4) 05/09/2019
   --
   ELSIF SUBSTR(pnnumnif, 1, 1) = '8'
         AND LENGTH(pnnumnif) = 1 THEN
      SELECT TO_CHAR(scodsd.NEXTVAL, 'fm0000000000')
        INTO secuencia
        FROM DUAL;

      znnumnif :=88 || '' || secuencia; 
   --     
   -- Fin IAXIS-4832(4) 05/09/2019   
   --
   ELSE
      znnumnif := pnnumnif;
   END IF;

   RETURN 0;
END;

/