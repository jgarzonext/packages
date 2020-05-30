--------------------------------------------------------
--  DDL for Package PAC_LISTA_PER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LISTA_PER" authid current_user IS
/***********************************************************************************************
    PAC_LISTA_PER: Package per omplir i treballar amb les llistes de valors de persones.
        ALLIB014
        Modificació codi_consulta VARCHAR2(20) --> codi_consulta VARCHAR2(100)
************************************************************************************************/
  type lista is record(
    codi     varchar2(6),
    texte    varchar2(50),
    texte1     varchar2(10),
    busqueda    varchar2(223)
  );
  type lista_ref is ref cursor return lista;
  type lista_tab is table of lista index by binary_integer;

  procedure query  (resultset in out lista_ref);

  codi_consulta    VARCHAR2(100);
  var_idioma    NUMBER;
  condicion    VARCHAR2(55);

  procedure omplir_consulta (camp IN VARCHAR2, pidioma IN NUMBER);
  procedure omplir_condicion (valor IN VARCHAR2);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_LISTA_PER" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LISTA_PER" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LISTA_PER" TO "PROGRAMADORESCSI";
