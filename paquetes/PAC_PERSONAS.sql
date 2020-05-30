--------------------------------------------------------
--  DDL for Package PAC_PERSONAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PERSONAS" AUTHID CURRENT_USER
IS

  codigo_espanya  CONSTANT NUMBER(3) := nvl(f_parinstalacion_n('PAIS_DEF'),0);

-------------------------------------------------
---creado APD 28-03-2007 Gestión de personas ----
-------------------------------------------------
  FUNCTION FF_PERTENECE_PAIS_UE (pcpais NUMBER) RETURN NUMBER;
  FUNCTION FF_NACIONALIDAD_PRINCIPAL (psperson NUMBER) RETURN NUMBER;
  FUNCTION F_VALIDA_TIPO_SUJETO (psperson NUMBER, pcsujeto NUMBER DEFAULT NULL, pcpais NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION FF_CALCULA_TIPO_SUJETO (pcpais NUMBER) RETURN NUMBER;

  -- MSR 31/7/2007
  -- Valida si a una persona li falta el NIE
  --   Es considera que li falta el NEI si
  --    1.- No te la nacionalitat espanyola
  --    2.- Cap de les seves nacionalitats te definit el NIE
  --
  --  En cas que li falti el NIE torna 1
  --
  --  Paràmetres
  --    sPerson     Obligatori
  --    pFecha      Opcional. Si s'informa es valida que no estigui caducat
  FUNCTION FF_FALTA_NIE(psperson IN PERSONAS.SPERSON%TYPE, pFecha IN DATE DEFAULT NULL) RETURN NUMBER;
-- MSR 25/09/2007. A la versió 10g no passa la validació.
--  PRAGMA RESTRICT_REFERENCES(FF_FALTA_NIE, WNDS);  -- En temps de compilació ens assegurem que es pot utilitzar a dins d'un SELECT


  -- MSR 13/8/2007
  -- Retorna un literal de fins 1500 caràcters amb l'adreça de la persona.
  --  És una interficie per cridar F_DIRECCION però que es pot utilitzar dins un Select
  --
  --  Paràmetres
  --    pcFormat    Valors:
  --                    1  Retorna el carrer, codi postal, provincia i país
  --                    2  Retorna el carrer i el codi postal
  --    psPerson     Obligatori. Identificador de la persona
  --    pcDomici     Obligatori. Codi de l'adreça.
  FUNCTION FF_DIRECCION(pcformat IN NUMBER, psperson IN PERSONAS.SPERSON%TYPE, pcdomici IN DIRECCIONES.CDOMICI%TYPE) RETURN VARCHAR2;
-- MSR 25/09/2007. A la versió 10g no passa la validació.
--  PRAGMA RESTRICT_REFERENCES(FF_DIRECCION, WNDS);  -- En temps de compilació ens assegurem que es pot utilitzar a dins d'un SELECT

  FUNCTION F_VALIDA_MISMA_DIRECCION (psperson1 IN NUMBER, pcdomici1 IN NUMBER, psperson2 IN NUMBER, pcdomici2 OUT NUMBER) RETURN NUMBER;

END PAC_PERSONAS; 
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_PERSONAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PERSONAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PERSONAS" TO "PROGRAMADORESCSI";
