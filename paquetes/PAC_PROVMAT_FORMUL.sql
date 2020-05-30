--------------------------------------------------------
--  DDL for Package PAC_PROVMAT_FORMUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROVMAT_FORMUL" AUTHID CURRENT_USER
IS
-- Variables Globales
   FUNCTION f_commit_calcul_pm_formul (
      pcempres   IN   NUMBER,
      pfcalcul   IN   DATE,
      psproces   IN   NUMBER,
      pcidioma   IN   NUMBER,
      pcmoneda   IN   NUMBER,
      pmodo      IN   VARCHAR2 DEFAULT 'R'
   )
      RETURN NUMBER;

   FUNCTION f_calcul_pm_seguro (
      psseguro   IN   NUMBER,
      pfcalcul   IN   DATE,
      pmodo      IN   VARCHAR2 DEFAULT 'R'
   )
      RETURN NUMBER;

   FUNCTION f_ins_garansegprovmat (psseguro IN NUMBER)
      RETURN NUMBER;

   --  28-3-2007. Función que nos devolverá el valor solicitado de la tabla EVOLUPROVMATSEG A UNA FECHA
   FUNCTION ff_evolu (
      porigen      IN   NUMBER,
      pvalor       IN   NUMBER,
      psseguro     IN   NUMBER,
      pnmovimi     IN   NUMBER,
      pnanyo       IN   NUMBER,
      pnscenario   IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER;

   -- 28-3-2007. Función que devuelve el resultado de la fórmula asignada al campo que se le pasa por parámetro
   -- Bug 10690 - RSC - 22/12/2009 - APR - Provisiones en productos de cartera (PORTFOLIO)
   -- Añadimos pcgarant y pndetgar
    -- Ini Bug 24704 --ECP-- 26/04/2013
   FUNCTION f_calcul_formulas_provi (
      psseguro   IN   NUMBER,
      pfecha     IN   DATE,
      pcampo     IN   VARCHAR2,
      pcgarant   IN   NUMBER DEFAULT NULL,
      pndetgar   IN   NUMBER DEFAULT NULL,
      psituac    IN   NUMBER DEFAULT 1,
      psesion    IN   NUMBER DEFAULT NULL,
      pnmovimi   IN   NUMBER DEFAULT NULL,
      pnrecibo   IN   NUMBER DEFAULT NULL,
      pnsinies   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;
-- Fin Bug 24704 --ECP-- 26/04/2013
END pac_provmat_formul;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROVMAT_FORMUL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROVMAT_FORMUL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROVMAT_FORMUL" TO "PROGRAMADORESCSI";
