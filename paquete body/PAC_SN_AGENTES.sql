--------------------------------------------------------
--  DDL for Package Body PAC_SN_AGENTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SN_AGENTES" 
AS
/*
 * Autor:
 *   JBP8301 ('Sa Nostra' Assegurances)
 * Data:
 *   15 de maig 2007
 * Descripció:
 *   Funcions per a validar codis d'agent i comprovar si pertanyen o no
 *   a una branca de l'estructura d'arbre dins la taula redcomercial.
 */

--*----
-- JBP8301 T.1383 (abril 2007)
-- Procés:  Comprova que pcagente és descendent de pcpadre a 
--          la taula redcomercial.
-- Retorna: 1 quan l'agent pertany a cpadre
--          0 quan l'agent no pertany a cpadre o no existeix
--*----
   FUNCTION f_agen_pertenece_a (
      pcagente   NUMBER,                                    -- Codi d'agent
      pcpadre    NUMBER                                -- Branca de l'arbre
   )
      RETURN NUMBER
   IS
      valor    NUMBER;
      punter   NUMBER;
   BEGIN
      valor := pcagente;

      IF f_existe(pcagente) = 0              -- Existència del codi d'agent
      THEN
         RETURN 0;
      END IF;

      WHILE valor != 9001              -- Mentre no és a l'arrel de l'arbre
       AND valor != pcpadre
       AND valor IS NOT NULL                     -- i no té com a pare NULL
      LOOP
         punter := valor;                               -- Avança el punter

         SELECT rc.cpadre
           INTO valor
           FROM redcomercial rc
          WHERE rc.cagente = punter
            AND rc.fmovfin IS NULL;
      END LOOP;

      IF valor = pcpadre
      THEN
         RETURN 1;
      END IF;
      
      RETURN 0;
      
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;         
   END f_agen_pertenece_a;
--
--
--*----
-- JBP8301 T.1383 (abril 2007):
-- Procés:  Determina si un codi d'agent és d'oficines o no.
-- Retorna: 1 si el codi pertany a la xarxa comercial
--          0 si no pertany a la xarxa comercial
--*----
   FUNCTION f_es_oficina (pcagente NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      IF f_agen_pertenece_a (pcagente, 10000) = 1
      THEN
         RETURN 1;
      END IF;
      
      RETURN 0;
      
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;
   END;
--
--
--*----
-- JBP8301 T.1383 (abril 2007):
-- Procés:  Determina si un codi d'agent és departamental o no.
-- Retorna: 1 si el codi pertany a departaments
--          0 si el codi no pertany a departaments
--*----
   FUNCTION f_es_departamento (pcagente NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      IF f_agen_pertenece_a (pcagente, 9002) = 1
      THEN
         RETURN 1;
      END IF;
      
      RETURN 0;
      
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;
   END;
--
--
--*----
-- JBP8301 T.1383 (abril 2007):
-- Procés:  Determina si un codi d'agent existeix o no a la taula redcomercial.
-- Retorna: 1 si el codi existeix
--          0 si el codi no existeix
--*----
   FUNCTION f_existe (pcagente NUMBER)
      RETURN NUMBER
   IS
      qty   NUMBER;
   BEGIN
   
      SELECT count(1)
        INTO qty
        FROM redcomercial rc
       WHERE rc.cagente = pcagente;
       
      IF qty = 1
      THEN
         RETURN 1;
      END IF;
      
      RETURN 0;
      
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;
   END;
END pac_sn_agentes; 

/

  GRANT EXECUTE ON "AXIS"."PAC_SN_AGENTES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SN_AGENTES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SN_AGENTES" TO "PROGRAMADORESCSI";
