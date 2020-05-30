--------------------------------------------------------
--  DDL for Package PAC_DUPLICAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DUPLICAR" IS
-----------------------------------------------------------------------------
-- Declaracion de tipos y variables globales de paquete
-----------------------------------------------------------------------------
   TYPE registro IS TABLE OF VARCHAR2(32000)
      INDEX BY BINARY_INTEGER;

   TYPE vector IS TABLE OF registro
      INDEX BY BINARY_INTEGER;

   resultado      vector;

   FUNCTION f_dup_producto(
      ramorig IN NUMBER,
      modaliorig IN NUMBER,
      tipsegorig IN NUMBER,
      colectorig IN NUMBER,
      ramdest IN NUMBER,
      modalidest IN NUMBER,
      tipsegdest IN NUMBER,
      colectdest IN NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      psalida IN NUMBER DEFAULT NULL,
      producdest IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_dup_contrato(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      psalida IN NUMBER DEFAULT NULL,
      ramdest IN NUMBER DEFAULT NULL,
      modalidest IN NUMBER DEFAULT NULL,
      tipsegdest IN NUMBER DEFAULT NULL,
      colectdest IN NUMBER DEFAULT NULL,
      pactividest IN NUMBER DEFAULT NULL,
      pgarantdest IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_dup_actividad(
      ramorig IN NUMBER,
      modaliorig IN NUMBER,
      tipsegorig IN NUMBER,
      colectorig IN NUMBER,
      activiorig IN NUMBER,
      actividest IN NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      psalida IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_borra_producto(
      ramo IN NUMBER,
      modali IN NUMBER,
      tipseg IN NUMBER,
      colect IN NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      psalida IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_comp_productos(
      ramorig IN NUMBER,
      modaliorig IN NUMBER,
      tipsegorig IN NUMBER,
      colectorig IN NUMBER,
      ramdest IN NUMBER,
      modalidest IN NUMBER,
      tipsegdest IN NUMBER,
      colectdest IN NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      psalida IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- 16/07/2012 - MDS - 0022824: LCOL_T010-Duplicado de propuestas
   FUNCTION f_dup_seguro(
      sseguroorig IN NUMBER,
      pfefecto IN DATE,
      pobservaciones IN VARCHAR2,
      ssegurodest IN OUT NUMBER,
      nsolicidest OUT NUMBER,
      npolizadest OUT NUMBER,
      ncertifdest OUT NUMBER,
      tipotablas IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL) --RAMIRO
      RETURN NUMBER;

   -- 17/06/2013 - RCL - 26923: Revisión Q-Trackers Fase 3A
   FUNCTION f_valida_dup_seguro(sseguroorig IN NUMBER)
      RETURN NUMBER;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_DUPLICAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DUPLICAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DUPLICAR" TO "PROGRAMADORESCSI";
