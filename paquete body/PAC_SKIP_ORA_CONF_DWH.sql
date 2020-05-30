create or replace PACKAGE BODY pac_skip_ora IS
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
      1.6        27/03/2014   JMF                7.Afegir MATERIALIZED VIEW
      1.7        27/03/2014   NMM                8.23760: Index associat a constraint.

   ******************************************************************************/
   objectconstraint CONSTANT VARCHAR2(20) := 'CONSTRAINT';
   objectcolumn CONSTANT VARCHAR2(20) := 'COLUMNS';

   /*************************************************************************
      Comprova si el nom de l'índex es diu igual que la constraint. Si es diu
      diferent també caldrà esborrar l'índex.
      param in pnomconstraint:   Nom de la constraint que volem esborrar.

      return             : null / nom del índex
   *************************************************************************/
   FUNCTION f_indexassociat(pnomconstraint IN VARCHAR2)
      RETURN VARCHAR2 IS
      windexname     VARCHAR2(1000);
   --wConstraintName varchar2(1000);
   BEGIN
      SELECT index_name
        INTO windexname
        FROM user_constraints
       WHERE constraint_name = pnomconstraint;

      IF windexname <> pnomconstraint THEN
         RETURN(windexname);
      END IF;

      RETURN(NULL);
   EXCEPTION
      WHEN OTHERS THEN
         AXIS.p_tab_error(AXIS.f_sysdate(), NVL(AXIS.f_user(), 'AXIS'), 'pac_skip_ora.f_indexAssociat', NULL
                   , 'OTHERS', SQLERRM);
         RETURN(NULL);
   END f_indexassociat;

   FUNCTION f_mirasiexisteix(
      pnomobjecte IN VARCHAR2
    , ptipusobjecte IN VARCHAR2
    , pcolumn IN VARCHAR2 DEFAULT NULL)
      RETURN BOOLEAN IS
      wfferdrop      INTEGER := 0;
   BEGIN
      IF ptipusobjecte IN(objecttable
                        , objecttype
                        , objectindex
                        , objectsequence
                        , 'MATERIALIZED VIEW') THEN
         SELECT COUNT(*)
           INTO wfferdrop
           FROM user_objects
          WHERE object_name = pnomobjecte
            AND object_type = ptipusobjecte;
      ELSIF ptipusobjecte = objectconstraint THEN
         SELECT COUNT(*)
           INTO wfferdrop
           FROM user_constraints
          WHERE constraint_name = pnomobjecte;
      ELSIF ptipusobjecte = objectcolumn THEN
         SELECT COUNT(*)
           INTO wfferdrop
           FROM user_tab_columns
          WHERE table_name = pnomobjecte
            AND column_name = pcolumn;
      END IF;

      RETURN(wfferdrop > 0);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN(FALSE);
   END f_mirasiexisteix;

   FUNCTION f_checkremove(
      pnomobjecte IN VARCHAR2
    , ptipusobjecte IN VARCHAR2
    , pcolumn IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
   BEGIN
      IF f_mirasiexisteix(pnomobjecte, ptipusobjecte, pcolumn) THEN
         RETURN(1);
      END IF;

      RETURN(0);
   END f_checkremove;

   /*************************************************************************
      Comprova si s'ha de fer drop o no cal d'un objecte.
      param in pnomobjecte:   Nom de l'objecte del qual es vol fer drop
      param in ptipusobjecte: Tipus d'objecte ( TABLE, TYPE, INDEX).

      return             : 0 objecte exiteix i s'ha borrat, 1 l'objecte no s'ha borrat, -1 error others
   *************************************************************************/
   FUNCTION f_comprovadrop(pnomobjecte IN VARCHAR2, ptipusobjecte IN VARCHAR2)
      RETURN NUMBER IS
      wferdrop       BOOLEAN := FALSE;
   --
   --
   BEGIN
      wferdrop := f_mirasiexisteix(pnomobjecte, ptipusobjecte);

      -- En cas que calgui fer drop, mirem si és una taula, type o index.
      IF wferdrop THEN
         --
         IF ptipusobjecte = 'TABLE' THEN
            EXECUTE IMMEDIATE 'DROP TABLE ' || pnomobjecte || ' PURGE';

            -- en aquest cas és imprescindible l'ús de dbms_output
            DBMS_OUTPUT.put_line('-> Drop Table: ' || pnomobjecte);
            RETURN f_checkremove(pnomobjecte, ptipusobjecte);
         --
         ELSIF ptipusobjecte = 'TYPE' THEN
            --
            EXECUTE IMMEDIATE 'DROP TYPE ' || pnomobjecte || ' FORCE';

            -- en aquest cas és imprescindible l'ús de dbms_output
            DBMS_OUTPUT.put_line('-> Drop Type: ' || pnomobjecte);
            RETURN f_checkremove(pnomobjecte, ptipusobjecte);
         --
         ELSIF ptipusobjecte = 'INDEX' THEN
            --
            EXECUTE IMMEDIATE 'DROP INDEX ' || pnomobjecte;

            -- en aquest cas és imprescindible l'ús de dbms_output
            DBMS_OUTPUT.put_line('-> Drop Index: ' || pnomobjecte);
            RETURN f_checkremove(pnomobjecte, ptipusobjecte);
         --
         ELSIF ptipusobjecte = 'SEQUENCE' THEN
            --
            EXECUTE IMMEDIATE 'DROP SEQUENCE ' || pnomobjecte;

            -- en aquest cas és imprescindible l'ús de dbms_output
            DBMS_OUTPUT.put_line('-> Drop Sequence: ' || pnomobjecte);
            RETURN f_checkremove(pnomobjecte, ptipusobjecte);
         --
         ELSIF ptipusobjecte = 'MATERIALIZED VIEW' THEN
            --
            EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || pnomobjecte;

            -- en aquest cas és imprescindible l'ús de dbms_output
            DBMS_OUTPUT.put_line('-> Drop MATERIALIZED VIEW: ' || pnomobjecte);
            RETURN f_checkremove(pnomobjecte, ptipusobjecte);
         END IF;
      --
      ELSE
         -- en aquest cas és imprescindible l'ús de dbms_output
         DBMS_OUTPUT.put_line('-> Object: ' || pnomobjecte || ' doesn''t exist. No Drop.');
      END IF;

      -- Si va bé, retornarà un zero. Si retorna 1, és que per algún motiu no ha fet el drop.
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         AXIS.p_tab_error(AXIS.f_sysdate, NVL(AXIS.f_user(), 'AXIS'), 'pac_skip_ora.f_comprovadrop', NULL
                   , 'OTHERS', SQLERRM);
         DBMS_OUTPUT.put_line('ORA-11217 ' || SQLERRM);
         RETURN -1;
   END f_comprovadrop;

   /*************************************************************************
      Comprova si s'ha de fer drop o no cal d'una constraint
      param in pnomconstraint:   Nom de la constraint que volem esborrar.
      param in ptaulaconstraint: Nom de la taula a la que pertany la constraint.

      return             : 0 correcte / 1,-1 incorrecte
   *************************************************************************/
   FUNCTION f_comprovaconstraint(
      pnomconstraint IN VARCHAR2
    , ptaulaconstraint IN VARCHAR2
    , pcascade IN BOOLEAN DEFAULT FALSE)
      RETURN NUMBER IS
      --
      wexisteix      INTEGER;
      wferdrop       BOOLEAN := FALSE;
      wcascade       VARCHAR2(100) := NULL;
      wnomindex      VARCHAR2(1000) := NULL;
   --
   BEGIN
      wferdrop := f_mirasiexisteix(pnomconstraint, objectconstraint);
      -----------------------------------------------------------------------
      -- Mirem si l'índex associat a la constraint es diu igual.
      wnomindex := f_indexassociat(pnomconstraint);

      -----------------------------------------------------------------------
      IF wferdrop THEN
         IF pcascade THEN
            wcascade := ' CASCADE';
         --
         END IF;

         -- ALTER TABLE nom_taula DROP CONSTRAINT nom_constraint
         EXECUTE IMMEDIATE 'ALTER TABLE ' || ptaulaconstraint || ' DROP CONSTRAINT '
                           || pnomconstraint || wcascade;

         -- en aquest cas és imprescindible l'ús de dbms_output
         DBMS_OUTPUT.put_line('-> Drop constraint: ' || pnomconstraint);

         -----------------------------------------------------------------------
         IF wnomindex IS NOT NULL THEN
            EXECUTE IMMEDIATE 'DROP INDEX ' || wnomindex;

            -- en aquest cas és imprescindible l'ús de dbms_output
            DBMS_OUTPUT.put_line('-> Drop index associat: ' || wnomindex);
         END IF;

         -----------------------------------------------------------------------
         RETURN f_checkremove(pnomconstraint, objectconstraint);
      ELSE
         -- en aquest cas és imprescindible l'ús de dbms_output
         DBMS_OUTPUT.put_line('-> Constraint: ' || pnomconstraint
                              || ' doesn''t exist. No drop.');
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         AXIS.p_tab_error(AXIS.f_sysdate, NVL(AXIS.f_user(), 'AXIS'), 'pac_skip_ora.f_ComprovaConstraint'
                   , NULL, 'OTHERS', SQLERRM);
         DBMS_OUTPUT.put_line('ORA-11217 ' || SQLERRM);
         RETURN -1;
   END f_comprovaconstraint;

   /*************************************************************************
      PROCEDURE f_ComprovaColumn
      comprova si existeix una columna abans de crear-la
      param in ptaula   : Nom de la taula
      param in pcolumna : Nom de la columna que volem comprovar.

      return              : 0 correcte / 1,-1 incorrecte
   *************************************************************************/
   FUNCTION f_comprovacolumn(ptaula IN VARCHAR2, pcolumn IN VARCHAR2)
      RETURN NUMBER IS
      --
      wexisteix      INTEGER;
      w_resultat     NUMBER := 0;
      -- Si val 1 fer drop, 0 no cal drop.
      w_ferdrop      BOOLEAN := FALSE;
   --
   BEGIN
      w_ferdrop := f_mirasiexisteix(ptaula, objectcolumn, pcolumn);

      -- ALTER TABLE nom_taula DROP COLUMN nom_columna.
      IF w_ferdrop THEN
         EXECUTE IMMEDIATE 'ALTER TABLE ' || ptaula || ' DROP COLUMN ' || pcolumn;

         -- en aquest cas és imprescindible l'ús de dbms_output
         DBMS_OUTPUT.put_line('-> Drop column: ' || pcolumn);
         RETURN f_checkremove(ptaula, objectcolumn, pcolumn);
      ELSE
         -- en aquest cas és imprescindible l'ús de dbms_output
         DBMS_OUTPUT.put_line('-> Column: ' || pcolumn || ' doesn''t exist. No Drop.');
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         AXIS.p_tab_error(AXIS.f_sysdate, NVL(AXIS.f_user(), 'AXIS'), 'pac_skip_ora.f_ComprovaColumn', NULL
                   , 'OTHERS: Error .', SQLERRM);
         DBMS_OUTPUT.put_line('ORA-11217 ' || SQLERRM);
         RETURN -1;
   END f_comprovacolumn;

   --

   /*************************************************************************
        PROCEDURE f_ComprovaDrop
        comprova si s'ha de fer drop o no cal d'un objecte.
        param in p_NomObjecte:   Nom de l'objecte del qual es vol fer drop
        param in p_tipusobjecte: Tipus d'objecte ( TABLE, TYPE, INDEX).

        return             : 0 correcte / 1,-1 incorrecte
     *************************************************************************/
   PROCEDURE p_comprovadrop(pnomobjecte IN VARCHAR2, ptipusobjecte IN VARCHAR2) IS
      nerr           NUMBER;
   BEGIN
      IF f_comprovadrop(UPPER(pnomobjecte), UPPER(ptipusobjecte)) = 1 THEN
         DBMS_OUTPUT.put_line('-> Unable to remove');
         DBMS_OUTPUT.put_line('ORA-11220 Object exist ' || pnomobjecte);
      END IF;
   END p_comprovadrop;

   /*************************************************************************
      PROCEDURE f_comprovaconstraint
      comprova si s'ha de fer drop o no cal d'una constraint
      param in p_nom_constraint:   Nom de la constraint que volem esborrar.
      param in p_taula_constraint: Nom de la taula a la que pertany la constraint.

      return             : 0 correcte / 1,-1 incorrecte
   *************************************************************************/
   PROCEDURE p_comprovaconstraint(
      pnom_constraint IN VARCHAR2
    , ptaula_constraint IN VARCHAR2
    , pcascade IN BOOLEAN DEFAULT FALSE) IS
      nerr           NUMBER;
   BEGIN
      IF f_comprovaconstraint(UPPER(pnom_constraint), UPPER(ptaula_constraint), pcascade) = 1 THEN
         DBMS_OUTPUT.put_line('-> Unable to remove');
         DBMS_OUTPUT.put_line('ORA-11220 Object exist ' || pnom_constraint);
      END IF;
   END p_comprovaconstraint;

   /*************************************************************************
      PROCEDURE f_ComprovaColumn
      comprova si existeix una columna abans de crear-la
      param in pi_taula   : Nom de la taula
      param in pi_columna : Nom de la columna que volem comprovar.

      return              : 0 correcte / 1,-1 incorrecte
   *************************************************************************/
   PROCEDURE p_comprovacolumn(ptaula IN VARCHAR2, pcolumn IN VARCHAR2) IS
      nerr           NUMBER;
   BEGIN
      IF f_comprovacolumn(UPPER(ptaula), UPPER(pcolumn)) = 1 THEN
         DBMS_OUTPUT.put_line('-> Unable to remove');
         DBMS_OUTPUT.put_line('ORA-11220 Column exist ' || ptaula || '.' || pcolumn);
      END IF;
   END p_comprovacolumn;
END pac_skip_ora;

/