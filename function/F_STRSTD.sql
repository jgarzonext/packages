--------------------------------------------------------
--  DDL for Function F_STRSTD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_STRSTD" (ptentrada IN VARCHAR2, ptsalida IN OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_STRSTD: Transforma una cadena de caracteres con acentos en una cadena
          sin acentos
   ALLIBMFM.
   Se eliminan tambiÈn los caracteres ' I ', ' DE ', ' D' '
   Se eliminan tambien los puntos y las comas.
****************************************************************************/
   xtentrada      VARCHAR2(223);
   yentrada       VARCHAR2(223);
   zentrada       VARCHAR2(223);
BEGIN
---Eliminamos los blancos del principio y del final------------------
---------------------------------------------------------------------
   xtentrada := LTRIM(RTRIM(ptentrada));
---Cambiamos las letras acentuadas por su correspondiente------------
---------------------------------------------------------------------
   yentrada := TRANSLATE(xtentrada, 'Û”Ú“ˆ÷Ù‘·¡‡¿‰ƒ¿¬È…Ë»ÎÀÍ ÌÕÏÃÔœÓŒ˙⁄˘Ÿ¸‹˚€',
                         'ooooooooaaaaaaaaeeeeeeeeiiiiiiiiuuuuuuuu');
---Transformamos a may˙sculas-----------------------------------------
----------------------------------------------------------------------
   zentrada := UPPER(yentrada);
   -- ModificaciÛn. Se eliminan las ' i ', ' I ', ' y ', ' Y ',
   -- ' de ', ' DE ', ' d' ', ' D' '
   ptsalida :=
      REPLACE
         (REPLACE
              (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(zentrada, ' I ', ' '),
                                                               ' Y ', ' '),
                                                       ' DE ', ' '),
                                               ' D''', ' '),
                                       ', ', ' '),
                               ',', ' '),
                       '. ', ' '),
               CHR(39), CHR(39) || CHR(39)),   -- BUG 38344/217178 - 28/10/2015 - ACL
          '.', '');
   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 102842;   ---Error en la funciÛn f_strstd
END;

/

  GRANT EXECUTE ON "AXIS"."F_STRSTD" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_STRSTD" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_STRSTD" TO "PROGRAMADORESCSI";
