--------------------------------------------------------
--  DDL for Package PAC_IAX_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_PROCESOS" IS
/******************************************************************************
   NOMBRE:    PAC_IAX_PROCESOS
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha       Autor   Descripción
   ---------  ----------  -----   ------------------------------------
   1.0        22/02/10  JRB     Creació del package.

******************************************************************************/

   /***********************************************************************
      Comentarios
      param in  pSPROCES     : NUMBER
      param in  pFPROINI     : DATE
      param in  pCPROCES     : NUMBER
      param in  pNERROR      : NUMBER
      param in  pCUSUARI     : VARCHAR2
      param out mensajes     : T_IAX_MENSAJES
      return                 : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consultaprocesoscab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfproini IN DATE,
      pcproces IN VARCHAR2,
      pnerror IN NUMBER,
      pcusuari IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_procesoscab;

/***********************************************************************
      Comentarios
      param in  pSPROCES     : NUMBER
      param in out mensajes : T_IAX_MENSAJES
      return                : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consultaprocesoslin(psproces IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_procesoslin;
END pac_iax_procesos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROCESOS" TO "PROGRAMADORESCSI";
