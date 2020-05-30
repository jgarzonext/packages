--------------------------------------------------------
--  DDL for Package PK_AUTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_AUTOM" AS
   secuencia       NUMBER;
   depurar         NUMBER:=0;
   iniciar         NUMBER:=0;
   segmentos       NUMBER(6,0):=0;
   sub_segmentos   NUMBER(6,0):=0;
   long_grabada    NUMBER(5,0):=0;
   fecha           DATE;
   hora            VARCHAR2(4);
   EOF	           BOOLEAN:=FALSE;
   cond            BOOLEAN:=FALSE;
   cerrado         BOOLEAN := TRUE;
   retorno         VARCHAR2(20000);
   actualizar      BOOLEAN:=TRUE;
   aaproc          NUMBER(4,0);
   mmproc          NUMBER(2,0);
   entrada     UTL_FILE.File_Type;
   salida      UTL_FILE.File_Type;
   mensajes    UTL_FILE.File_Type;
   trazas      UTL_FILE.FILE_TYPE;
   varlin	   VARCHAR2(2000);
   ruta_entrada VARCHAR2(100);
   ruta_salida  VARCHAR2(100);
   fichero      VARCHAR2(100);
   doct         VARCHAR2(10);
   mensaje		VARCHAR2(10);
   sentido		VARCHAR2(1);
   PROCEDURE inicio(ano_proc IN NUMBER,
                    mes_proc IN NUMBER);
   PROCEDURE Traza(trazas IN UTL_FILE.FILE_TYPE,
      depurar IN NUMBER, msg IN VARCHAR2);
END pk_autom;

 
 

/

  GRANT EXECUTE ON "AXIS"."PK_AUTOM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_AUTOM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_AUTOM" TO "PROGRAMADORESCSI";
