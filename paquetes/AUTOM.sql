--------------------------------------------------------
--  DDL for Package AUTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."AUTOM" AS

   depurar         NUMBER:=0;
   n_empresa       NUMBER(4,0);
   aaproc          NUMBER(4,0);
   mmproc          NUMBER(2,0);
   iniciar         NUMBER:=0;
   empresas        NUMBER(5,0):=0;
   segmentos       NUMBER(5,0):=0;
   long_grabada    NUMBER(5,0):=0;
   FINIPROC        DATE;
   FFINPROC        DATE;
   tip_proc     VARCHAR2(1);
   fecha           DATE;
   hora            VARCHAR2(4);
   EOF	           BOOLEAN:=FALSE;
   cerrado         BOOLEAN := TRUE;
   retorno         VARCHAR2(100);
   actualizar      BOOLEAN:=TRUE;

  salida      UTL_FILE.File_Type;
  mensajes    UTL_FILE.File_Type;

   PROCEDURE inicio(nempresa IN NUMBER,
                    ano_proc IN NUMBER,
                    mes_proc IN NUMBER,
                    tipo_proc IN VARCHAR2);
END autom;

 
 

/

  GRANT EXECUTE ON "AXIS"."AUTOM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."AUTOM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."AUTOM" TO "PROGRAMADORESCSI";
