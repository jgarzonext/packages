--------------------------------------------------------
--  DDL for Package PAC_CTRL_ACCESO_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CTRL_ACCESO_MV" IS
/*-----------------------------------------------------------------------*/
/* CPM 27/1/04: Package per controlar l'accés dels diferents usuaris	 */
/* 	   			a les pòlisses i la seva informació			 			 */
/*-----------------------------------------------------------------------*/

   FUNCTION f_acceso_poliza (psperson IN NUMBER, ptipousu IN NUMBER,
		 				 poficina IN VARCHAR2) RETURN NUMBER ;

   FUNCTION tipo_usuario (puser in varchar2, ptipousuario out varchar2)
        RETURN NUMBER;

   FUNCTION usuario_host (puser IN VARCHAR2, puserhost OUT VARCHAR2) RETURN NUMBER;

   FUNCTION f_es_host (p_user IN VARCHAR2, p_host OUT NUMBER) RETURN NUMBER;


END  Pac_Ctrl_Acceso_MV;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_CTRL_ACCESO_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CTRL_ACCESO_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CTRL_ACCESO_MV" TO "PROGRAMADORESCSI";
