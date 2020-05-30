--------------------------------------------------------
--  DDL for Package PAC_IAX_GETCONSULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_GETCONSULT" AS

/******************************************************************************
   NOMBRE:       PAC_IAX_GETCONSULT
   PROPÓSITO:  Package que dada un SQL devuelve el objecto de la SQL y
               su definción

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/07/2007   ACC                1. Creación del package.
******************************************************************************/

   TYPE ref_cur_t IS REF CURSOR;

   squery          VARCHAR2 (32000);
   ncount          NUMBER;
   desc_tab        DBMS_SQL.desc_tab2;
   varchar2_type   CONSTANT PLS_INTEGER        := 1;
   number_type     CONSTANT PLS_INTEGER        := 2;
   date_type       CONSTANT PLS_INTEGER        := 12;
   rowid_type      CONSTANT PLS_INTEGER        := 11;
   char_type       CONSTANT PLS_INTEGER        := 96;

   /*long_type     CONSTANT PLS_INTEGER := 8;
   raw_type      CONSTANT PLS_INTEGER := 23;
   mlslabel_type CONSTANT PLS_INTEGER := 106;
   clob_type     CONSTANT PLS_INTEGER := 112;
   blob_type     CONSTANT PLS_INTEGER := 113;
   bfile_type    CONSTANT PLS_INTEGER := 114;*/

   -- Establece sentenia Sql
   PROCEDURE setQuery (sq VARCHAR2);

   -- Recupera las columnas definidas en la sentencia Sql
   PROCEDURE Describe_Columns;

   -- Devuelve la definición de los campos de la consulta
   -- para poder crear un type record dynamic
   -- return: la definición de la tabla como a SQL
   FUNCTION f_Record_Def
      RETURN VARCHAR2;

   -- Devuelve los nombres de los campos definidos en Sql
   -- return: el nombre de los campos de la tabla como  SQL
   FUNCTION f_Columns_Names
      RETURN VARCHAR2;

   -- Devuelve un cursor con la Sql
   -- return: un cursor como referencia de la SQL
   FUNCTION f_Ref_Cur
      RETURN ref_cur_t;

   -- Devuelve el tipo y tamaño de una columna
   -- param col: indica la posición de la columna a recuperar
   -- param typ: devuelve el tipo de valor
   -- param siz: devuelve la longitud del campo
   PROCEDURE GetTypeSizeCol (
      col   IN       NUMBER,
      typ   OUT      PLS_INTEGER,
      siz   OUT      VARCHAR2
   );

   -- Devuelve la tabla con los datos definidos en el SQL
   -- return: la definición como objeto de la SQL
   FUNCTION f_GetTableObj
      RETURN T_IAX_GETCONSULT;


   -- Devuelve la tabla con los datos definidos en el SQL como parámetro
   -- param: establece la SQL a procesar
   -- param out: devuelve la colección de mensajes
   -- return: devuelve la tabla de la consulta
   FUNCTION f_GetTable (squery VARCHAR2, mensaje OUT T_IAX_MENSAJES)
      RETURN T_IAX_GETCONSULT;

END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_GETCONSULT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GETCONSULT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_GETCONSULT" TO "PROGRAMADORESCSI";
