--------------------------------------------------------
--  DDL for Function FUSION_AGENTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FUSION_AGENTES" (cagent_origen IN NUMBER, cagent_desti IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/*-----------------------------------------------------------------------
     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        05/10/2007   JFD             se añade ctipban (tipo de CCC).
     2.0        11/11/2011   APD             se añade csobrecomisi, talias, cliquido (Bug 19169)
     3.0        01/03/2012   JMF             0021425 MDP - COM - AGENTES Sección datos generales

------------------------------------------------------------------------*/
   reg_orig       agentes%ROWTYPE;
   reg_desti      agentes%ROWTYPE;
   texto          VARCHAR2(200);
   pnnumlin       NUMBER;
   num_err        NUMBER;
BEGIN
   -- BUG 0021425 - 01/03/2012 - JMF
   SELECT *
     INTO reg_orig
     FROM agentes
    WHERE cagente = cagent_origen;

   SELECT *
     INTO reg_desti
     FROM agentes
    WHERE cagente = cagent_desti;

   BEGIN
      IF reg_desti.cdomici IS NULL
         AND reg_orig.cdomici IS NOT NULL THEN
         UPDATE agentes
            SET cdomici = reg_orig.cdomici
          WHERE cagente = cagent_desti;
      END IF;

      IF reg_desti.cbancar IS NULL
         AND reg_orig.cbancar IS NOT NULL THEN
         UPDATE agentes
            SET cbancar = reg_orig.cbancar
          WHERE cagente = cagent_desti;
      END IF;

      IF reg_desti.ncolegi IS NULL
         AND reg_orig.ncolegi IS NOT NULL THEN
         UPDATE agentes
            SET ncolegi = reg_orig.ncolegi
          WHERE cagente = cagent_desti;
      END IF;

      IF reg_desti.fbajage IS NULL
         AND reg_orig.fbajage IS NOT NULL THEN
         UPDATE agentes
            SET fbajage = reg_orig.fbajage
          WHERE cagente = cagent_desti;
      END IF;

      IF reg_desti.csoprec IS NULL
         AND reg_orig.csoprec IS NOT NULL THEN
         UPDATE agentes
            SET csoprec = reg_orig.csoprec
          WHERE cagente = cagent_desti;
      END IF;

      IF reg_desti.cmediop IS NULL
         AND reg_orig.cmediop IS NOT NULL THEN
         UPDATE agentes
            SET cmediop = reg_orig.cmediop
          WHERE cagente = cagent_desti;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104581;
   END;

   --Ahora borramos el registro de AGENTES
   BEGIN
      DELETE FROM agentes
            WHERE cagente = cagent_origen;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line('error : ' || SQLERRM);
         RETURN 104574;
   END;

   RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."FUSION_AGENTES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FUSION_AGENTES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FUSION_AGENTES" TO "PROGRAMADORESCSI";
