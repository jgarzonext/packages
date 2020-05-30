create or replace PACKAGE pac_skip_ora IS
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

   
END pac_skip_ora;

/