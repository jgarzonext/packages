--------------------------------------------------------
--  DDL for Package PK_RECHAZO_MOVIMIENTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_RECHAZO_MOVIMIENTO" IS
------------------------------------------------------------------------------------------------------
---modificado XCG 05-01-2007 afegim el camp SEGUROS_AHO.NDURPER en la funció F_anulacion_suplemento---
------------------------------------------------------------------------------------------------------
   --INICIO 32009 - DCT - 11/07/2014.- Añadir parámetro poriduplic
   FUNCTION f_anulacion_propuesta(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      paccion IN NUMBER,
      poriduplic IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   --FIN 32009 - DCT - 11/07/2014.- Añadir parámetro poriduplic

   --INICIO 32009 - DCT - 11/07/2014.- Añadir parámetro poriduplic
   -- Bug 0011936 - JMF - 14/01/2010: f_rechazo Afegir movimient.
   FUNCTION f_rechazo(
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      paccion IN NUMBER,
      ptobserv IN VARCHAR2,
      pnmovimi IN NUMBER DEFAULT NULL,
      pnorec IN NUMBER DEFAULT 0,   -- PACCION: 3 ANULACION 4.- RECHAZO
      poriduplic IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
--FIN 32009 - DCT - 11/07/2014.- Añadir parámetro poriduplic
END pk_rechazo_movimiento;

/

  GRANT EXECUTE ON "AXIS"."PK_RECHAZO_MOVIMIENTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_RECHAZO_MOVIMIENTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_RECHAZO_MOVIMIENTO" TO "PROGRAMADORESCSI";
