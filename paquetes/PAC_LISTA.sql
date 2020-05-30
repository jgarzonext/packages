--------------------------------------------------------
--  DDL for Package PAC_LISTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LISTA" authid current_user IS
/***********************************************************************************************
    PAC_LISTA: Package per omplir i treballar amb les llistes de valors.
    ALLIBP01 - Package de llistes de valors
        Se añaden las lista de 'LISTA DE MOVIMIENTOS DE SEGURO'
                                y 'LISTA DE DOCUMENTOS'
************************************************************************************************/
  type lista is record(
    codi         varchar2(5),
    texte        varchar2(50),
    busqueda    varchar2(55)
  );
  type lista_ref is ref cursor return lista;
  type lista_tab is table of lista index by binary_integer;
  procedure query  (resultset in out lista_ref);
  codi_consulta    VARCHAR2(20);
  var_idioma    NUMBER;
  condicion        VARCHAR2(55);
  procedure omplir_consulta (camp IN VARCHAR2, pidioma IN NUMBER);
  procedure omplir_condicion (valor IN VARCHAR2);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_LISTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LISTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LISTA" TO "PROGRAMADORESCSI";
