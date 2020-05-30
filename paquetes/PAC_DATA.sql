--------------------------------------------------------
--  DDL for Package PAC_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DATA" AUTHID CURRENT_USER AS
  --
  --  Aquets package està posat per incloure diferents funcions relacionades amb el tractament de les dades
  --

  --
  --  Format
  --      Formateja adeuqadaments un format de data.
  --      Te en compte l'idioma, apostrofar i coses similars
  --
  --  Exemple :
  --    1.-  Format : 'DD Month YYYY'              Idioma : Espanyol         24 Agosto 2007
  --    2.-  Format : 'FM DD "de" Month "de" YYYY' Idioma : Catala           24 d'Agost de 2007
  --    3.-  Format : 'FM DD "de" Month "de" YYYY' Idioma : Espanyol         24 de Agosto de 2007
  --
  FUNCTION Format (pData IN DATE, pFormat IN VARCHAR2, pcIdioma IN IDIOMAS.CIDIOMA%TYPE DEFAULT F_IDIOMAUSER) RETURN VARCHAR2;
 -- PRAGMA RESTRICT_REFERENCES(Format, WNDS);  -- En temps de compilació ens assegurem que es pot utilitzar a dins d'un SELECT

END PAC_DATA; 
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_DATA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DATA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DATA" TO "PROGRAMADORESCSI";
