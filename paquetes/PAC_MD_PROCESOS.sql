--------------------------------------------------------
--  DDL for Package PAC_MD_PROCESOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PROCESOS" IS
/******************************************************************************
   NOMBRE:    PAC_MD_PROCESOS
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
      param in out mensajes : T_IAX_MENSAJES
      return              : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consultaprocesoscab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfproini IN DATE,
      pcproces IN VARCHAR2,
      pnerror IN NUMBER,
      pcusuari IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_procesoscab;

/***********************************************************************
      Comentarios
      param in  pSPROCES     :
      param in out mensajes : T_IAX_MENSAJES
      return                : ref cursor
   ***********************************************************************/
   FUNCTION f_set_consultaprocesoslin(psproces IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_procesoslin;
END pac_md_procesos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PROCESOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROCESOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROCESOS" TO "PROGRAMADORESCSI";
