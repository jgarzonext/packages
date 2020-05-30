--------------------------------------------------------
--  DDL for Package Body PAC_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_DATA" AS
  --
  --  Aquets package està posat per incloure diferents funcions relacionades amb el tractament de les dades
  --

  --
  --  Format
  --      Formateja adequadament un format de data segon l'idioma.
  --      Te en compte apostrofar i coses similars
  --
  --  Exemple :
  --    1.-  Format : 'DD Month YYYY'              Idioma : Espanyol         24 Agosto 2007
  --    2.-  Format : 'FM DD "de" Month "de" YYYY' Idioma : Catala           24 d'Agost de 2007
  --    3.-  Format : 'FM DD "de" Month "de" YYYY' Idioma : Espanyol         24 de Agosto de 2007
  --
  FUNCTION Format (pData IN DATE, pFormat IN VARCHAR2, pcIdioma IN IDIOMAS.CIDIOMA%TYPE DEFAULT F_IDIOMAUSER) RETURN VARCHAR2 IS
    v_data    VARCHAR2(2000);
--    v_format  VARCHAR2(2000);
  BEGIN
    CASE pcIdioma
      WHEN 1 THEN
        v_data := TO_CHAR(pData,pFormat,'NLS_DATE_LANGUAGE=CATALAN');
        -- Posar apòstrofs
        IF INSTR(pFormat,'"de" ') > 0 THEN
          v_data := REPLACE(v_data,'de A','d''A');
          v_data := REPLACE(v_data,'de O','d''O');
        END IF;

        IF INSTR(pFormat,'"el" ') > 0 THEN
          v_data := REPLACE(v_data,'el A','l''A');
          v_data := REPLACE(v_data,'el O','l''O');
        END IF;
      WHEN 2 THEN
        v_data := TO_CHAR(pData,pFormat,'NLS_DATE_LANGUAGE=SPANISH');
--    Exemples per altres idiomes per si algun dia calen
--    Anglès
--      WHEN ? THEN
--        v_format := REPLACE(pFormat,'DD "de"','DDTH');
--        v_format := REPLACE(v_Format,'"de"','"of"');
--        v_data := TO_CHAR(pData,v_Format,'NLS_DATE_LANGUAGE=ENGLISH');
--        END IF;
--    Francès
--      WHEN ? THEN
--        v_data := TO_CHAR(pData,pFormat,'NLS_DATE_LANGUAGE=FRENCH');
--        IF INSTR(pFormat,'"de" ') > 0 THEN
--          v_data := REPLACE(v_data,'de A','d''A');
--          v_data := REPLACE(v_data,'de O','d''O');
--        END IF;
--    Portuguès
--      WHEN ? THEN
--        v_data := TO_CHAR(pData,pFormat,'NLS_DATE_LANGUAGE=PORTUGUESE');
--        IF INSTR(pFormat,'"de" ') > 0 THEN
--          v_data := REPLACE(v_data,'de A','d''A');
--          v_data := REPLACE(v_data,'de O','d''O');
--        END IF;
--    Italià
--      WHEN ? THEN
--        v_format := REPLACE(pFormat,'"de"','"da"');
--        v_data := TO_CHAR(pData,v_Format,'NLS_DATE_LANGUAGE=ITALIAN');
--        IF INSTR(pFormat,' "de" ') > 0 THEN
--          v_data := REPLACE(v_data,'da A','d''A');
--          v_data := REPLACE(v_data,'da O','d''O');
--        END IF;
      ELSE
        v_data := TO_CHAR(pData,pFormat);
    END CASE;

    RETURN v_data;
  END;

END PAC_DATA; 

/

  GRANT EXECUTE ON "AXIS"."PAC_DATA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DATA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DATA" TO "PROGRAMADORESCSI";
