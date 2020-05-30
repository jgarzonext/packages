create or replace PACKAGE pac_listvalores AS

	        /******************************************************************************
         NOMBRE:       PAC_LISTVALORES
         PROPOSITO:  Funciones para recuperar valores

         REVISIONES:
         Ver        Fecha        Autor   Descripción
        ---------  ----------  ------   ------------------------------------
         1.0        16/11/2007   ACC     1. Creación del package.
                    11/02/2009   FAL     Cobradores, delegaciones. Bug: 0007657
                    11/02/2009   FAL     Tipos de apunte, Estado apunte, en/de la agenda. Bug: 0008748
                    12/02/2009   AMC     Siniestros de baja. Bug: 9025
                    06/03/2009   JSP     Agenda de poliza. Bug: 0009208
         2.0        28/10/2019   SGM     2. IAXIS-6149: Realizar consulta de personas publicas
		 ******************************************************************************/

   FUNCTION f_opencursor(squery IN VARCHAR2)
      RETURN sys_refcursor;

   FUNCTION f_get_consulta(
      codigo IN VARCHAR2,
      condicion IN VARCHAR2,
      pcidioma IN NUMBER,
      numerror IN OUT NUMBER)
      RETURN sys_refcursor;

--SGM IAXIS-6149 28/10/2019      
   FUNCTION f_get_publicinfo(
      codigo IN VARCHAR2,
      condicion IN VARCHAR2,
      pcidioma IN NUMBER,
      numerror IN OUT NUMBER)
      RETURN sys_refcursor;      
END pac_listvalores;
