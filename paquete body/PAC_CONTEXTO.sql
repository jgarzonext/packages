--------------------------------------------------------
--  DDL for Package Body PAC_CONTEXTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CONTEXTO" IS
   --Define las varibles tipos contexto
   cxtidioma      VARCHAR2(100) := 'IAX_IDIOMA';
   cxtusuario     VARCHAR2(100) := 'IAX_USUARIO';
   cxtagente      VARCHAR2(100) := 'IAX_AGENTE';
   cxtempresa     VARCHAR2(100) := 'IAX_EMPRESA';
   cxtagenteprod  VARCHAR2(100) := 'IAX_AGENTEPROD';
   cxtterminal    VARCHAR2(100) := 'IAX_TERMINAL';
   -- Jlb
   cxtdebug       VARCHAR2(20) := 'DEBUG';

   PROCEDURE p_contextoasignaparametro(
      pcnomcontexto IN VARCHAR2,
      pcnomparametro IN VARCHAR2,
      pvalparametro IN VARCHAR2
   ) IS
   BEGIN
      -- Funcion que asigna un parametro y un valor al contexto de personas
      DBMS_SESSION.set_context(pcnomcontexto, pcnomparametro, pvalparametro);

      IF pcnomparametro = 'nombre' THEN
         DBMS_APPLICATION_INFO.set_module(pvalparametro, NULL);
         DBMS_APPLICATION_INFO.
         set_action('Hora: ' || TO_CHAR(f_sysdate, 'DD/MM/YYYY HH24:MI:SS'));
      END IF;
   END p_contextoasignaparametro;

   FUNCTION f_contextovalorparametro(pcnomcontexto IN VARCHAR2, pcnomparametro IN VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
      -- Funcion que devuelve el valor de uno de los par¿metros del contexto pasados por parametro
      RETURN SYS_CONTEXT(pcnomcontexto, pcnomparametro);
   END f_contextovalorparametro;


   --BUG9903 02/06/2009 MSR : Contexte per defecte
   PROCEDURE p_contextoasignaparametro(
      pcnomparametro IN VARCHAR2,
      pvalparametro IN VARCHAR2
   ) IS
   BEGIN
      p_contextoasignaparametro(context_user, pcnomparametro, pvalparametro);
   END;

   FUNCTION f_contextovalorparametro(pcnomparametro IN VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN f_contextovalorparametro(context_user, pcnomparametro);
   END;

   --FI BUG9903 02/06/2009 MSR : Contexte per defecte


   -- *** 0007870:  Inicializar atributos contextuales en nuevas sesiones y parametrizaci¿n de las im¿genes para los listados

   -- Funcion para inicilizar los atributos contextuales
   FUNCTION f_inicializarctx(
      pcusuari IN usuarios.cusuari%TYPE,
      pterminal IN VARCHAR2 DEFAULT NULL
   )
      RETURN NUMBER IS
      v_cidioma      idiomas.cidioma%TYPE;
      v_cempres      empresas.cempres%TYPE;
      v_agente       agentes.cagente%TYPE;
      v_debug        usuarios.ndebug%TYPE;
   BEGIN
      SELECT   cidioma, cempres, cdelega, nvl(ndebug,1)
        INTO   v_cidioma, v_cempres, v_agente, v_debug
        FROM   usuarios
       WHERE   cusuari = pcusuari;

      --BUG9903 27/07/2009 MSR : Utilitzo la constant Context_User
      p_contextoasignaparametro(context_user, cxtusuario, pcusuari);
      p_contextoasignaparametro(context_user, 'nombre', pcusuari);
      p_contextoasignaparametro(context_user, cxtempresa, v_cempres);
      p_contextoasignaparametro(context_user, 'empresa', v_cempres);
      p_contextoasignaparametro(context_user, 'empresasel', v_cempres);
      p_contextoasignaparametro(context_user, 'multiempres', v_cempres);
      p_contextoasignaparametro(context_user, cxtidioma, v_cidioma);
      p_contextoasignaparametro(context_user, 'usu_idioma', v_cidioma);
      p_contextoasignaparametro(context_user, cxtagente, v_agente);
      p_contextoasignaparametro(context_user, cxtagenteprod, v_agente);
      p_contextoasignaparametro(context_user, cxtterminal, pterminal);
      --FI BUG9903 27/07/2009 MSR : Utilitzo la constant Context_User
      -- jlb - optmizaci¿n en cargas
      p_contextoasignaparametro(context_user, cxtdebug, v_debug); -- nivel de debug para el usuario, by default 1, s¿lo errores

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_inicializarctx;
END pac_contexto;

/

  GRANT EXECUTE ON "AXIS"."PAC_CONTEXTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CONTEXTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CONTEXTO" TO "PROGRAMADORESCSI";
