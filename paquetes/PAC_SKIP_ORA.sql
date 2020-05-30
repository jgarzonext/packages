--------------------------------------------------------
--  DDL for Package PAC_SKIP_ORA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SKIP_ORA" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:       PAC_SKIP_ORA
      PROPÓSITO: Funciones per controlar els errors ORA

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        10/12/2010   NMM                1.Creació. Bug 16867: Evitar falses alarmes errors ORA en instal·lar patchs
      1.1        07/02/2011   NMM                2.Bug 17070:S'afegeix la funció f_InsertLiteral per l'entorn d'apra
      1.2        31/03/2011   NMM                3.Bug 17070:S'afegeix opcionalment CASCADE per CONSTRAINTS i Funció ComprovaColumn.
      1.3        18/11/2011   NMM                4.Es passen les funcions a procediments.
      1.4        06/12/2011   ACC                5.Redefinició del package.
      1.5        10/05/2012   NMM                6.Afegir control de seqüències.

   ******************************************************************************/
   objecttable CONSTANT VARCHAR2(20) := 'TABLE';
   objecttype CONSTANT VARCHAR2(20) := 'TYPE';
   objectindex CONSTANT VARCHAR2(20) := 'INDEX';
   objectsequence CONSTANT VARCHAR2(20) := 'SEQUENCE';

   /*************************************************************************
      PROCEDURE f_ComprovaDrop
      comprova si s'ha de fer drop o no cal d'un objecte.
      param in p_NomObjecte:   Nom de l'objecte del qual es vol fer drop
      param in p_tipusobjecte: Tipus d'objecte ( TABLE, TYPE, INDEX).
                Utilitzar constants objecttable objecttype objectindex

      return             : 0 correcte / 1,-1 incorrecte
   *************************************************************************/
   PROCEDURE p_comprovadrop(pnomobjecte IN VARCHAR2, ptipusobjecte IN VARCHAR2);

   /*************************************************************************
      PROCEDURE f_comprovaconstraint
      comprova si s'ha de fer drop o no cal d'una constraint
      param in p_nom_constraint:   Nom de la constraint que volem esborrar.
      param in p_taula_constraint: Nom de la taula a la que pertany la constraint.

      return             : 0 correcte / 1,-1 incorrecte
   *************************************************************************/
   PROCEDURE p_comprovaconstraint(
      pnom_constraint IN VARCHAR2,
      ptaula_constraint IN VARCHAR2,
      pcascade IN BOOLEAN DEFAULT FALSE);

   /*************************************************************************
      PROCEDURE f_InsertLiteral
      comprova si existeix l'idioma d'un literal abans de crear-lo
      param in pi_cidioma : Codi d'idioma del literal
      param in pi_texte   : Texte del literal
      param in pi_slitera : Codi numèric del literal
      param in pi_clitera : Tipus de literal ( només per forms)

      return              : 0 correcte / 1,-1 incorrecte
   *************************************************************************/
   PROCEDURE p_insertliteral(
      pi_cidioma IN NUMBER,
      pi_texte IN VARCHAR,
      pi_slitera IN NUMBER,   -- codi literal
      pi_clitera IN NUMBER DEFAULT 1);

   -- tipus de literal ( només per forms)

   /*************************************************************************
      PROCEDURE f_ComprovaColumn
      comprova si existeix una columna abans de crear-la
      param in pi_taula   : Nom de la taula
      param in pi_columna : Nom de la columna que volem comprovar.

      return              : 0 correcte / 1,-1 incorrecte
   *************************************************************************/
   PROCEDURE p_comprovacolumn(ptaula IN VARCHAR2, pcolumn IN VARCHAR2);
END pac_skip_ora;

/

  GRANT EXECUTE ON "AXIS"."PAC_SKIP_ORA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SKIP_ORA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SKIP_ORA" TO "PROGRAMADORESCSI";
