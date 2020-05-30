--------------------------------------------------------
--  DDL for Package PAC_INTERFAZ_DATECSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_INTERFAZ_DATECSA" IS
   /******************************************************************************
      NOMBRE:    PAC_INTERFAZ_DATECSA
      PROP¿SITO: Funciones Interface Datecsa

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        20/09/2016  NMM              1. Creaci¿n del objeto.

   ******************************************************************************/
   -- global variables
   WSPROCES       NUMBER := 0;
   mensajes       t_iax_mensajes;
   WDATECSA_LIN   NUMBER := 0;
   WSSEGURO       SEGUROS.SSEGURO%TYPE;
   WSPERSON       PER_PERSONAS.SPERSON%TYPE;
   WCODE          NUMBER;
   WNAME          VARCHAR2(1000);
   wline          VARCHAR2(10000);
   wlinebak       VARCHAR2(10000);
   TYPE           SP9TYPE IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
   WSP9TAB        SP9TYPE;
   WNOM_PDF       VARCHAR2(1000);
   --
   /*************************************************************************
      PROCEDURE P_GEST_ERROR
   *************************************************************************/
   PROCEDURE P_GEST_ERROR;
   /*************************************************************************
      FUNCTION F_EJECUTA_INTERFAZ_DATECSA
      pcode  : Id fichero
      return : number
   *************************************************************************/
   FUNCTION F_EJECUTA_INTERFAZ_DATECSA
        ( pcode     IN NUMBER
        , pname     IN VARCHAR2
        , pnamepdf  IN VARCHAR2) RETURN NUMBER;
   --
   /*************************************************************************
      FUNCTION F_DIR_DATECSA
      return  : number
   *************************************************************************/
   FUNCTION F_DIR_DATECSA RETURN NUMBER;
   --
   /*************************************************************************
      PROCEDURE P_EXEC_DATECSA
   *************************************************************************/
   PROCEDURE P_EXEC_DATECSA;
   --
   /*************************************************************************
      PROCEDURE P_EXEC_DATECSA
   *************************************************************************/
   PROCEDURE DATECSA_TRACE ( p1 in varchar2, p2 in varchar2, p3  in varchar2);
   --
END PAC_INTERFAZ_DATECSA;

/

  GRANT EXECUTE ON "AXIS"."PAC_INTERFAZ_DATECSA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INTERFAZ_DATECSA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INTERFAZ_DATECSA" TO "PROGRAMADORESCSI";
