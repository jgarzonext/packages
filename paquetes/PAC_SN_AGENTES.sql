--------------------------------------------------------
--  DDL for Package PAC_SN_AGENTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SN_AGENTES" 
IS
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
   FUNCTION f_agen_pertenece_a (pcagente NUMBER, pcpadre NUMBER)
      RETURN NUMBER;
--
--
--*----
-- JBP8301 T.1383 (abril 2007):
-- Procés:  Determina si un codi d'agent és d'oficines o no.
-- Retorna: 1 si el codi pertany a la xarxa comercial
--          0 si no pertany a la xarxa comercial
--*----
   FUNCTION f_es_oficina (pcagente NUMBER)
      RETURN NUMBER;
--
--
--*----
-- JBP8301 T.1383 (abril 2007):
-- Procés:  Determina si un codi d'agent és departamental o no.
-- Retorna: 1 si el codi pertany a departaments
--          0 si el codi no pertany a departaments
--*----
   FUNCTION f_es_departamento (pcagente NUMBER)
      RETURN NUMBER;
--
--
--*----
-- JBP8301 T.1383 (abril 2007):
-- Procés:  Determina si un codi d'agent existeix o no a la taula redcomercial.
-- Retorna: 1 si el codi existeix
--          0 si el codi no existeix
--*----
   FUNCTION f_existe (pcagente NUMBER)
      RETURN NUMBER;
--
--      
END pac_sn_agentes; 
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_SN_AGENTES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SN_AGENTES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SN_AGENTES" TO "PROGRAMADORESCSI";
