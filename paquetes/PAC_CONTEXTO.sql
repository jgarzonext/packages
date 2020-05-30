--------------------------------------------------------
--  DDL for Package PAC_CONTEXTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CONTEXTO" IS
/****************************************************************************
   NOM:       PAC_CONTEXTO
   PROP¿SIT:

   REVISIONS:
   Ver        Data        Autor             Descripci¿
   ---------  ----------  ---------------  ----------------------------------
   1.0        ??????????
   1.1        27/04/2009   MSR              Optimitzaci¿
   1.2        02/06/2009   MSR              Posar funcions pel context per defecte
****************************************************************************/
   --BUG9903 27/07/2009 MSR : Es defineix aquesta constant per evitar accedir a F_PARINTALACION_T
   Context_User   CONSTANT VARCHAR2(30)  := F_PARINSTALACION_T('CONTEXT_USER');
--  Tot aix¿ no est¿ definit perqu¿ no ¿s compatible amb PAC_IAX_LOGIN
--   cidioma        CONSTANT IDIOMAS.CIDIOMA%TYPE := SYS_CONTEXT (Context_User,'IAX_IDIOMA');
--   cxtusuario     CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_USUARIO');
--   cxtagente      CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_AGENTE');
--   cempresa       CONSTANT EMPRESAS.CEMPRESA%TYPE) := SYS_CONTEXT (Context_User,'IAX_EMPRESA');
--   cxtagenteprod  CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_AGENTEPROD');
--   cxtterminal    CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'IAX_TERMINAL');
--   nombre         CONSTANT VARCHAR2(100) := SYS_CONTEXT (Context_User,'NOMBRE');
   --FI BUG9903 27/07/2009 MSR : Es defineix aquesta constant per evitar accedir a F_PARINTALACION_T


   PROCEDURE p_contextoasignaparametro (
      pcnomcontexto    IN   VARCHAR2,
      pcnomparametro   IN   VARCHAR2,
      pvalparametro    IN   VARCHAR2);

-- Funcion que devuelve el valor de uno de los par¿metros del contexto pasados por parametro
   FUNCTION f_contextovalorparametro (
      pcnomcontexto    IN   VARCHAR2,
      pcnomparametro   IN   VARCHAR2)
      RETURN VARCHAR2;

   --BUG9903 02/06/2009 MSR : Context per defecte
   PROCEDURE p_contextoasignaparametro (
      pcnomparametro   IN   VARCHAR2,
      pvalparametro    IN   VARCHAR2);

   FUNCTION f_contextovalorparametro (
      pcnomparametro   IN   VARCHAR2)
      RETURN VARCHAR2;
   --FI BUG9903 02/06/2009 MSR : Context per defecte


-- *** 0007870: Inicializar atributos contextuales en nuevas sesiones y parametrizaci¿n de las im¿genes para los listados
-- Funcion para inicilizar los atributos contextuales
   FUNCTION F_InicializarCTX (pcusuari IN USUARIOS.CUSUARI%TYPE,pterminal IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;
END pac_contexto;

/

  GRANT EXECUTE ON "AXIS"."PAC_CONTEXTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CONTEXTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CONTEXTO" TO "PROGRAMADORESCSI";
